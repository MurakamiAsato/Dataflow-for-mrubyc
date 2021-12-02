Nodes_Hash={:Nd6aad=>{:type=>"inject", :repeat=>"", :wires=>[[:Nb700d]], :inputNodeid=>[], :last_time=>0.0, :flow_controll=>1},
 :Nb700d=>{:type=>"GPIO", :ReadType=>"ADC", :GPIOType=>"read", :targetPort_digital=>"12", :targetPort_ADC=>"7", :wires=>[[:N85279, :N3937f]], :inputNodeid=>[:Nd6aad]},
 :N85279=>{:type=>"switch", :rules=>[{:t=>"gte", :v=>"1.5", :vt=>"num"}, {:t=>"lt", :v=>"1.5", :vt=>"str"}], :repair=>false, :outputs=>2, :wires=>[[:Na30b8], [:N5abeb]], :inputNodeid=>[:Nb700d]},
 :Na30b8=>{:type=>"LED", :LEDtype=>"GPIO", :targetPort=>"15", :targetPort_mode=>"2", :onBoardLED=>"0", :wires=>[], :inputNodeid=>[:N85279]},
 :N5abeb=>{:type=>"LED", :LEDtype=>"GPIO", :targetPort=>"16", :targetPort_mode=>"2", :onBoardLED=>"0", :wires=>[], :inputNodeid=>[:N85279]},
 :N3937f=>{:type=>"function", :wires=>[[]], :inputNodeid=>[:Nb700d], :flow_endFlg=>0}}
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
        Dataprocessing(node_id,:create,[Nodes_Hash[node_id][:flow_controll]])
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

def Node_GPIO(node_id)

    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)  
    if input_array == []
      return 0
    end

    input = 0

    input_array.each do |input_data|
        if input_data == 0
            return 0
        end
        
    end
    
    if "read" == Nodes_Hash[node_id][:GPIOType]
        if "digital_read" == Nodes_Hash[node_id][:ReadType]
            input = digitalRead(Nodes_Hash[node_id][:targetPort_digital].to_i)
        end

        if "ADC" == Nodes_Hash[node_id][:ReadType]
            adc = ADC.new()
            adc.ch(Nodes_Hash[node_id][:targetPort_ADC].to_i)
            adc.start
            sleep(0.001)
            input = adc.read_v
            adc.stop
        end
        Dataprocessing(node_id,:create,[input])
        return 0
    end

    #後日実装!!
    if "write" == Nodes_Hash[node_id][:GPIOType]

        input_array.each do |input_data|
            

            if "digital_write" == Nodes_Hash[node_id][:WriteType]
                targetPort = Nodes_Hash[node_id][:targetPort_digital].to_i
                targetPort_mode = Nodes_Hash[node_id][:targetPort_mode].to_i

                if targetPort_mode == 2
                    if input_data != 1
                        digitalWrite(targetPort,0)
                        output = 0
                    else
                        digitalWrite(targetPort,1)
                        output = 1
                    end
                else
                    if input_data != 1
                        next
                    else
                        digitalWrite(targetPort,targetPort_mode)
                        output = 1
                    end
                end
            end

        end
        return 0
    end
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


#this is function Node
def FunctionNode_N3937f(msg)
data = msg 

#電圧値をターミナルで表示するプログラム
puts data
end

def Node_function(node_id)
    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)
    if input_array == []
        return 0
    end
    output = 0

    input_array.each do |input_data|
        if input_data == 0 || input_data == ""
            return 0
        end
    
        if node_id == :N3937f
            output = FunctionNode_N3937f(input_data)
        end
        
    end
    Dataprocessing(node_id,:create,[output])
end
    

while true
Node_inject(:Nd6aad)
Node_GPIO(:Nb700d)
Node_switch(:N85279)
Node_LED(:Na30b8)
Node_LED(:N5abeb)
Node_function(:N3937f)
sleep(0.01)
end