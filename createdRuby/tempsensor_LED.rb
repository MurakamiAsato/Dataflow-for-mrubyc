Nodes_Hash={:N5af97=>{:type=>"inject", :repeat=>"1", :wires=>[[:Ndfdb9]], :inputNodeid=>[], :last_time=>0.0, :flow_controll=>1},
 :Ndfdb9=>{:type=>"Constant", :C=>"1", :wires=>[[:N6b5e5]], :inputNodeid=>[:N5af97]},
 :N6b5e5=>{:type=>"I2C", :ad=>68, :rules=>[{:t=>"W", :v=>33, :c=>48, :de=>"16"}, {:t=>"W", :v=>224, :c=>0, :de=>""}, {:t=>"R", :v=>0, :b=>"6", :de=>""}], :wires=>[[:N762c6]], :inputNodeid=>[:Ndfdb9]},
 :N762c6=>{:type=>"function", :wires=>[[:N28e5e]], :inputNodeid=>[:N6b5e5]},
 :N28e5e=>{:type=>"switch", :rules=>[{:t=>"gte", :v=>"24.0", :vt=>"str"}, {:t=>"lt", :v=>"24.0", :vt=>"str"}], :repair=>false, :outputs=>2, :wires=>[[:N28082], [:N913f7]], :inputNodeid=>[:N762c6]},
 :N28082=>{:type=>"LED", :LEDtype=>"GPIO", :targetPort=>"15", :targetPort_mode=>"2", :onBoardLED=>"", :wires=>[], :inputNodeid=>[:N28e5e]},
 :N913f7=>{:type=>"LED", :LEDtype=>"GPIO", :targetPort=>"16", :targetPort_mode=>"2", :onBoardLED=>"", :wires=>[], :inputNodeid=>[:N28e5e]}}
DatasBuffer = []

/---ノード間のデータやり取りを制御するデータ制御部---/
def Dataprocessing(node_id, mode, output = "")
    /get:データの取り出し deleet:自分宛のデータの削除 create:次ノード宛のデータの作成/
    get_datas = []
    if mode == :get
        DatasBuffer.each do |data|
            if node_id == data[1]
                get_datas << data[2]
            end
        end
        if Nodes_Hash[node_id][:inputNodeid].length > get_datas.length
            get_datas = []
        end
    end
    index = 0
    if mode == :delete
        DatasBuffer.each do |data|
            if node_id == data[1]
                DatasBuffer.delete_at(index)
            end
            index += 1
        end
    end
    if mode == :create
        if Nodes_Hash[node_id].has_key?(:flow_endFlg)
            return 0
        end
        output_index = 0
        Nodes_Hash[node_id][:wires].each do |wires|
            wires.each do |wire|
                index = 0
                DatasBuffer.each do |data|
                    if [node_id ,wire] == [data[0], data[1]] 
                        DatasBuffer.delete_at(index)
                        break
                    end
                    index += 1
                end
                DatasBuffer << [node_id ,wire, output[output_index]]
            end
            output_index += 1
        end
    end
    return get_datas
end
/---injectノードのノードプログラム---/
def Node_inject(node_id)
    if Nodes_Hash[node_id][:repeat] != ""
        /一定時間間隔が設定されている場合/
        /「0」と「1」を交互に送信する/
        if GetTime(node_id) == 1
            if Nodes_Hash[node_id][:flow_controll] == 1
                Nodes_Hash[node_id][:flow_controll] = 0
            elsif Nodes_Hash[node_id][:flow_controll] == 0
                Nodes_Hash[node_id][:flow_controll] = 1
            end
            Dataprocessing(node_id,:create,[Nodes_Hash[node_id][:flow_controll]])
        end
        return 0
    else
        /一定時間間隔が設定されていな場合/
        /「1」を常に送信し続ける/
        Dataprocessing(node_id,:create,[1])
        return 0
    end
end

def GetTime(node_id)

    if Nodes_Hash[node_id][:type] == "inject"
        repeat_time = Nodes_Hash[node_id][:repeat].to_f
    end

    if Nodes_Hash[node_id][:type] == "delay"
        repeat_time = Nodes_Hash[node_id][:timeout].to_f
    end

    run_time = VM.tick()/1000.0
    last_time = Nodes_Hash[node_id][:last_time]
    last_time = run_time - last_time

    if last_time >= repeat_time
        Nodes_Hash[node_id][:last_time] = run_time
        return 1
    else
        return 0
    end
end

/---Constantノードのノードプログラム---/
def Node_Constant(node_id)
  input_array = Dataprocessing(node_id,:get)
  Dataprocessing(node_id,:delete)
  if input_array == []
    return 
  end
  Dataprocessing(node_id,:create,[Nodes_Hash[node_id][:C].to_i])  
end

/I2Cノードのノードプログラム/
def Node_I2C(node_id)
    /データ有無の確認/
    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)
    if input_array == []
        return 0
    end
    input_array.each do |input_data|
        if input_data == 0
            return 0
        end
    end
    /本機能/
    sraveAd = Nodes_Hash[node_id][:ad].to_i
    output = []
    Nodes_Hash[node_id][:rules].each do |rule|
        if rule[:t] == "W"
            I2C.write(sraveAd, rule[:v].to_i, rule[:c].to_i)
        else
            output = I2C.read(sraveAd, rule[:v].to_i, rule[:b].to_i)
        end

        if rule[:de] != ""
            sleep_ms(rule[:de].to_i)
        end
    end
    Dataprocessing(node_id,:create,[output])
end

/---function-rubyノードのノードプログラム---/
def FunctionNode_N762c6(msg)
    data = msg
    temp = (data[0]<<8 |data[1])
    celsius = -45 + (175*temp/65535.0)

    puts "----------------------------"
    puts celsius
    return celsius
end

def Node_function(node_id)
    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)
    if input_array == []
        return 0
    end
    output = 0
    /ユーザーが作成した自作メソッドの呼び出し/
    input_array.each do |input_data|
 
    
        if node_id == :N762c6
            output = FunctionNode_N762c6(input_data)
        end
        
    end
    Dataprocessing(node_id,:create,[output])
end
    
/---switchノードのノードプログラム---/

def Node_switch(node_id)
    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)
    if input_array == []
      return 0
    end

    input_array.each do |input_data|
        if input_data == "" 
          return 0
        end
    end
    output_flg = []
    #本機能
    #各入力データに対し、各出力点に対する条件と比較を行う。
    input_array.each do |input_data|
        count = 0
        Nodes_Hash[node_id][:rules].each do |rules_element|
    
            if rules_element[:t] == "lt"
                if input_data < rules_element[:v].to_f
                    output_flg << 1
                else
                    output_flg << 0
                end
            end
         
            if rules_element[:t] == "gte"
                if input_data >= rules_element[:v].to_f
                    output_flg << 1
                else
                    output_flg << 0
                end
            end
            
            count += 1
        end
    end
    Dataprocessing(node_id,:create,output_flg)
end

/---LEDノードのノードプログラム---/

def GPIO_digital_mode2(node_id,input)
    if input == 0
        digitalWrite(Nodes_Hash[node_id][:targetPort].to_i,0)
    elsif input == 1
        digitalWrite(Nodes_Hash[node_id][:targetPort].to_i,1)
    end
end
    
def Node_LED(node_id)
    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)  
    if input_array == []
      return 0
    end
    /本機能/
    input_array.each do |input|
    
            if Nodes_Hash[node_id][:targetPort_mode] == "2" && Nodes_Hash[node_id][:LEDtype] == "GPIO"
                GPIO_digital_mode2(node_id,input)
            end

    end
end

/---各ノードを呼び出す司令塔(loop処理)---/
while true
Node_inject(:N5af97)
Node_Constant(:Ndfdb9)
Node_I2C(:N6b5e5)
Node_function(:N762c6)
Node_switch(:N28e5e)
Node_LED(:N28082)
Node_LED(:N913f7)
sleep(0.01)
end