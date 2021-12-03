Nodes_Hash={:Nab692=>{:type=>"inject", :repeat=>"1", :wires=>[[:N2bf48]], :inputNodeid=>[], :last_time=>0.0, :flow_controll=>1},
 :Nd64ea=>{:type=>"I2C", :ad=>68, :rules=>[{:t=>"W", :v=>33, :c=>48, :de=>"16"}, {:t=>"W", :v=>224, :c=>0, :de=>""}, {:t=>"R", :v=>0, :b=>"6", :de=>""}], :wires=>[[:N59ab8]], :inputNodeid=>[:N2bf48]},
 :N59ab8=>{:type=>"function", :wires=>[[:N89df2]], :inputNodeid=>[:Nd64ea]},
 :N2bf48=>{:type=>"Constant", :C=>"1", :wires=>[[:Nd64ea]], :inputNodeid=>[:Nab692]},
 :N89df2=>{:type=>"switch", :rules=>[{:t=>"gte", :v=>"24.0", :vt=>"num"}, {:t=>"lt", :v=>"24.0", :vt=>"num"}], :repair=>false, :outputs=>2, :wires=>[[:N1c6e1], [:Naf01a]], :inputNodeid=>[:N59ab8]},
 :N1c6e1=>{:type=>"LED", :LEDtype=>"GPIO", :targetPort=>"15", :targetPort_mode=>"2", :onBoardLED=>"0", :wires=>[], :inputNodeid=>[:N89df2]},
 :Naf01a=>{:type=>"LED", :LEDtype=>"GPIO", :targetPort=>"16", :targetPort_mode=>"2", :onBoardLED=>"0", :wires=>[], :inputNodeid=>[:N89df2]}}
DatasBuffer = []

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
def Node_inject(node_id)
    if Nodes_Hash[node_id][:repeat] != ""
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

#this is function Node
def FunctionNode_N59ab8(msg)
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

    input_array.each do |input_data|
 
    
        if node_id == :N59ab8
            output = FunctionNode_N59ab8(input_data)
        end
        
    end
    Dataprocessing(node_id,:create,[output])
end
    

def Node_Constant(node_id)
  input_array = Dataprocessing(node_id,:get)
  Dataprocessing(node_id,:delete)
  if input_array == []
    return 
  end
  Dataprocessing(node_id,:create,[Nodes_Hash[node_id][:C].to_i])  
end

#this is switch Node

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

#this is LED Node

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
      
    input_array.each do |input|
    
            if Nodes_Hash[node_id][:targetPort_mode] == "2" && Nodes_Hash[node_id][:LEDtype] == "GPIO"
                GPIO_digital_mode2(node_id,input)
            end

    end
end


while true
Node_inject(:Nab692)
Node_I2C(:Nd64ea)
Node_function(:N59ab8)
Node_Constant(:N2bf48)
Node_switch(:N89df2)
Node_LED(:N1c6e1)
Node_LED(:Naf01a)
sleep(0.01)
end