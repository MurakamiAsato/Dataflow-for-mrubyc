#LEDノードの機能を必要な分だけ「LED.rb」に記述するプログラム
$created_node_parts = []

def Create_LEDnode(node, created_parts, mainFlg = false)
    $created_node_parts = created_parts
    parts = []
    #LED.rbの用意
    if $created_node_parts.include?(:LED_initialize) == false
        parts << LED_initialize()
    end
    #LEDノードの機能の記述
    parts << Write_LEDaction(node)

    if mainFlg == true
        $created_node_parts << parts
        $created_node_parts = $created_node_parts.flatten
        Write_LEDmain()
    end

    return parts

end

def LED_initialize()
    File.open("./Nodes/LED.rb", mode = "w"){|f|
    f.write("/---LEDノードのノードプログラム---/\n")  # ファイルに書き込む
    }

    return :LED_initialize
end

def Write_LEDaction(node)
    parts = []    
    File.open("./Nodes/LED.rb", mode = "a"){|f|

        if node[1][:LEDtype] == "GPIO"
            if node[1][:targetPort_mode] == "2" && $created_node_parts.include?(:GPIO_digital_mode2) == false
                f.write(LED_OnOffmode_code())
                parts << :GPIO_digital_mode2
            end
    
            if node[1][:targetPort_mode] != "2" && $created_node_parts.include?(:GPIO_digital_mode1) == false
                f.write(LED_mode_code())
                parts << :GPIO_digital_mode1
            end
        end
        if node[1][:LEDtype] == "onBoardLED" && $created_node_parts.include?(:LED_onBoard) == false
            f.write(LED_onBoard_code())
            parts << :LED_onBoard
        end
    }
    return parts
end

def Write_LEDmain()
    File.open("./Nodes/LED.rb", mode = "a"){|f|
        f.write(LED_main_code())
    }
end


def LED_OnOffmode_code()
    code = "
def GPIO_digital_mode2(node_id,input)
    if input == 0
        digitalWrite(Nodes_Hash[node_id][:targetPort].to_i,0)
    elsif input == 1
        digitalWrite(Nodes_Hash[node_id][:targetPort].to_i,1)
    end
 end
    "
    return code
end

def LED_mode_code()
    code = "
def GPIO_digital_mode1(node_id,input)
    if input == 1
        digitalWrite(Nodes_Hash[node_id][:targetPort].to_i,targetPort_mode,Nodes_Hash[node_id][:targetPort_mode].to_i)
    end
end
    "
    return code
end

def LED_onBoard_code()
    code = "
def LED_onBoard(node_id,input)
    if input == 1
        leds_write(Nodes_Hash[node_id][:onBoardLED].to_i)
    end
end
    "
end

def LED_main_code
    code = "
def Node_LED(node_id)
    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)  
    if input_array == []
      return 0
    end
    /本機能/
    input_array.each do |input|
    "
        if $created_node_parts.include?(:GPIO_digital_mode2)
            code = code + "
            if Nodes_Hash[node_id][:targetPort_mode] == \"2\" && Nodes_Hash[node_id][:LEDtype] == \"GPIO\"
                GPIO_digital_mode2(node_id,input)
            end\n"
        end
        if $created_node_parts.include?(:GPIO_digital_mode1)
            code = code + "
            if (Nodes_Hash[node_id][:targetPort_mode] == \"0\" || Nodes_Hash[node_id][:targetPort_mode] == \"1\") && Nodes_Hash[node_id][:LEDtype] == \"GPIO\"
                GPIO_digital_mode1(node_id,input)
            end\n"
        end
        if $created_node_parts.include?(:LED_onBoard)
            code = code + "
            if  Nodes_Hash[node_id][:LEDtype] == \"onBoardLED\"
                LED_onBoard(node_id,input)
            end\n"
        end

        code = code + "
    end
end
"

    return code

end