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

            if "PWM" == Nodes_Hash[node_id][:WriteType]
                PWM.new()
                PWM.pin(Nodes_Hash[node_id][:targetPort_PWM].to_i)
                PWM.start(Nodes_Hash[node_id][:PWM_num].to_i)
                PWM.cycle(Nodes_Hash[node_id][:time].to_i,Nodes_Hash[node_id][:double].to_i)
                PWM.rate(Nodes_Hash[node_id][:rate].to_i,Nodes_Hash[node_id][:PWM_num].to_i)
            end

        end
        return 0
    end
end