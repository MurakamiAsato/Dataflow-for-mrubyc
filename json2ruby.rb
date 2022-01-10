#.jsonファイルからRubyコードを生成する。
#オプション次第では、直接Rboardへバイトコードを送る。

/オプションの設定/
require 'optparse'
require 'json'
$compile_flg = false

option = {}
OptionParser.new do |opt|
  opt.on('-r Filename',   '読み込む.jsonファイル名を指定') {|name| option[:r] = name}
  opt.on('-w Filename',   'Rubyコードのファイル名を入力') {|name| option[:w] = name}
  opt.on('-d',   '生成したRubyコードのコンパイルとマイコンへの転送') {$compile_flg = true}
  opt.parse!(ARGV)
end


if option[:r] != nil
  jsonfilesname = option[:r]
else
  puts "---.jsonファイルを入力してください---"
  filenames = Dir.open("jsonFile",&:to_a)
  filenames.each do |filename|
    if filename.include?(".json") == true
      p filename
    end
  end
  jsonfilesname = gets().chomp()
end

if option[:w] != nil
  mrubyc_program = "./createdRuby/" + option[:w]
else
  mrubyc_program = "./createdRuby/mrubyc_program.rb"
end

puts "---"+ mrubyc_program +"を生成します。---"

/jsonファイルの読み込み/

begin
  jsonfilesname = "./jsonFile/" + jsonfilesname
  f = File.open(jsonfilesname)
  str = f.read
  JSON_hash = JSON.parse(str, symbolize_names: true)
  f.close
rescue Errno::ENOENT
  puts "入力された.jsonファイルは存在しません。"
  return 
end



/読み込んだjsonファイルのデータ整形/
JSON_hash.map do |element|
  if element[:type] == "tab" || element[:type] == "debug"
      element.clear()
      next
  end

 /不必要なプロパティの削除/
  element.delete(:z)
  element.delete(:name)
  element.delete(:x)
  element.delete(:y)
  element.delete(:props)
  element.delete(:crontab)
  element.delete(:once)
  element.delete(:onceDelay)
  element.delete(:topic)
  element.delete(:payload)
  element.delete(:payloadType)
  element.delete(:property)
  element.delete(:propertyType)
  element.delete(:checkall)
  element.delete(:noerr)
  element.delete(:initialize)
  element.delete(:finalize)
  element.delete(:libs)

  /ノードIDの簡略化/
  element[:wires] = element[:wires].map do |wires|    
    wires = wires.map do |wire|
      wire = "N" + wire.slice(0,5)
      wire = wire.to_sym
    end
  end

  element[:id] = element[:id].delete(".")
  element[:id]= "N" + element[:id].slice(0,5)
  element[:id] = element[:id].to_sym
end

/よりデータを扱いやすく加工　「{NodeID => {プロパティ}}」の仕様にする/
nodes_Hash = {}
JSON_hash.each do |element|

  element_id = element[:id]
  element.delete(:id)

  if element_id == nil
    next
  end

  nodes_Hash.store(element_id,element)
end


/対象ノードのidからinput先のノードidを抽出する関数/
def Find_InputID_fromID(node_id,nodes_Hash)
  get_id = []

  nodes_Hash.each do |element|
    element[1][:wires].each do |wires|
      wires.each do |wire|

        if wire == node_id
          get_id.push(element[0])
        end
      end
    end
  end

  return get_id
end

nodes_Hash.each do |element|

  /ノードに前で接続されているノードID情報を付与する/
  input_ID = Find_InputID_fromID(element[0],nodes_Hash)
  element[1].store("inputNodeid".to_sym, input_ID)


  #GPIOノード・function-Codeノード関連の「type」整理
  if element[1][:type].include?("GPIO")
    element[1][:type] = "GPIO"
  end
  if element[1][:type].include?("function-Code")
    element[1][:type] = "function"
  end


  #debugノードといった削除されたノードIDが入っている各ノードの「wires」の整理
  element[1][:wires].each do |wires_array|
    wires_array.each do |wires_ID| 
      if nodes_Hash.key?(wires_ID)
        next
      end
      wires_array.delete(wires_ID)
    end  
  end

  #フロー先のノードがない末端ノードに対して「終了フラグ」を付与
  element[1][:wires].each do |wires|
    if wires.length >= 1
      break
    end
    element[1].store("flow_endFlg".to_sym,0)
  end

  #injectノードに、タイマー管理を行えるよう情報付加
  if element[1][:type] == "inject"
    element[1].store("last_time".to_sym, 0.0)
    element[1].store("flow_controll".to_sym, 1)
  end
  if element[1][:type] == "delay"
    element[1].store("last_time".to_sym, 0.0)
    element[1].store("depo_data".to_sym, "")
  end

 #I2Cノードのコマンドを16進数から10進数に変換
 if element[1][:type] == "I2C"
    element[1][:ad] = Integer(element[1][:ad])
    element[1][:rules].each do |rules_element|

      rules_element[:v] = Integer(rules_element[:v])
      if rules_element.key?(:c)
        rules_element[:c] = Integer(rules_element[:c])
        
      end
    end
  end



end


#functionノードの機能を「function.rb」としてプログラムを作成する。
require "./Nodes/create_function.rb"
functionNode_ids = []
nodes_Hash.each do |element|
  if element[1][:type] == "function"

    if functionNode_ids.length == 0
      Function_initialize()
    end
    functionNode_ids << element[0]
    Write_function(element[0],element[1][:func])
    element[1].delete(:func)
  end
end
Write_Mainfunction(functionNode_ids)

#ノードの各タイプごとの数を計算。
node_num = {}
nodes_Hash.each do |node|
  if node_num.include?(node[1][:type])
    node_num[node[1][:type]]  += 1
  else
    node_num.store(node[1][:type],1)
  end
end

#nodes_Hash.each do |element|
#  p element[1][:type]
#end

#ノード機能を「node.rb」としてプログラムを作成する。
require "./Nodes/create_LED.rb"
require "./Nodes/create_switch.rb"

#ノード機能を部品的に各ノード.rbに記述していく。
#ノードによっては機能が全く同じものもあるため、生成したパーツ情報を管理する。
#例：LEDノードとGPIOノードにおけるPinの出力制御
created_node_parts = []
created_node_num = {}
nodes_Hash.each do |node|

  if created_node_num.include?(node[1][:type]) == false
    created_node_num.store(node[1][:type],0)
  end
  #LEDノードのプログラム記述
  if node[1][:type] == "LED"
    created_node_num["LED"] += 1
    if node_num["LED"] == created_node_num["LED"]
      created_node_parts << Create_LEDnode(node, created_node_parts, mainFlg = true)
    else
      created_node_parts << Create_LEDnode(node, created_node_parts)
    end
  end

  #switchノードのプログラム記述
  if node[1][:type] == "switch"
    created_node_num["switch"] += 1
    if node_num["switch"] == created_node_num["switch"]
      created_node_parts << Create_switchnode(node, created_node_parts, mainFlg = true)
    else
      created_node_parts << Create_switchnode(node, created_node_parts)
    end
  end
  created_node_parts = created_node_parts.flatten

end



/--------------Rboardに向けてソースプログラムを生成していく--------------/

Hash_Datas = nodes_Hash.to_s

#ノード群のデータ書き込み&ノード管理の実装&バッファーの実装
File.open(mrubyc_program, mode = "w"){|f|
  hash_txt = Hash_Datas.to_s
  hash_txt = hash_txt.gsub(/}, :N/,"},\n :N")
  f.write("Nodes_Hash="+hash_txt+"\n")  # ファイルに書き込む
  f.write("DatasBuffer = []\n")  # ファイルに書き込む

  writing_f = File.open("./Nodes/Dataprocessing.rb")
  tFile = writing_f.read
  writing_f.close
  f.write("\n")
  f.write(tFile)  # ファイルに書き込む
  f.write("\n") 
}

#各ノードのタイプに合わせた機能の実装
Stock_Type = []
nodes_Hash.each do |element|
  if Stock_Type.include?(element[1][:type])
    next
  end

  fileurl = "./Nodes/" + element[1][:type] +".rb"

  f = File.open(fileurl)
  tFile = f.read
  f.close
  File.open(mrubyc_program, mode = "a"){|f|
  f.write(tFile)  # ファイルに書き込む
  f.write("\n\n")

  }

  Stock_Type.push(element[1][:type])

end

#ピンモードの設定などのセットアップ群
count = 0

nodes_Hash.each do |element|
  if "GPIO" != element[1][:type] && "Button" != element[1][:type] && "LED" != element[1][:type]
    next
  end

  if "read" == element[1][:GPIOType]
    if "digital_read" == element[1][:ReadType]
      File.open(mrubyc_program, mode = "a"){|f|
      f.write("pinMode(#{element[1][:targetPort_digital]},1)\n")  # ファイルに書き込む
      }  
    end
    
  end

  if "Button" == element[1][:type] && element[1][:targetPort] != ""
    File.open(mrubyc_program, mode = "a"){|f|
      f.write("pinMode(#{element[1][:targetPort]},1)\n")  # ファイルに書き込む
      f.write("pinPull(#{element[1][:targetPort]},#{element[1][:selectPull]})\n") 
    }  
  end

  if "write" == element[1][:GPIOType]
    if "digital_write" == element[1][:WriteType]
      File.open(mrubyc_program, mode = "a"){|f|
      f.write("pinMode(#{element[1][:targetPort_digital]},0)\n")  # ファイルに書き込む
      }  
    end    
  end

  if "LED" == element[1][:type] && "using_LED" == element[1][:HOWuesLED]
    File.open(mrubyc_program, mode = "a"){|f|
      f.write("pinMode(#{element[1][:targetPort]},0)\n")  # ファイルに書き込む
    }  
  end

  count += 1

end


File.open(mrubyc_program, mode = "a"){|f|
  f.write("/---各ノードを呼び出す司令塔(loop処理)---/\n")
  f.write("while true\n")
  nodes_Hash.each do |element|
    
    f.write("Node_"+element[1][:type]+"(:"+element[0].to_s+")\n")

  end
  f.write("sleep(0.01)\n")
  f.write("end")
}


/-----------------------------------ここまで----------------------------------------------/


if $compile_flg == true
  puts "---コンパイルプログラムを起動---"
  mrubyc_program = mrubyc_program.gsub("./createdRuby/","")
  system("ruby convert_mrubyc.rb -r #{mrubyc_program}")
end