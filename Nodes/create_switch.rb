#switchノードの機能を必要な分だけ「switch.rb」に記述するプログラム
$created_node_parts = []

def Create_switchnode(node, created_parts, mainFlg = false)
    $created_node_parts = created_parts
    parts = []

    if $created_node_parts.include?(:Switch_initialize) == false
        parts << Switch_initialize()
    end

    parts << Write_switchrule(node)
    if mainFlg == true
        $created_node_parts << parts
        $created_node_parts = $created_node_parts.flatten
        Write_switchmain()
    end
    
    return parts

end

def Switch_initialize()
    File.open("./Nodes/switch.rb", mode = "w"){|f|
    f.write("/---switchノードのノードプログラム---/\n")  # ファイルに書き込む
    }
    return :Switch_initialize
end

def Write_switchrule(node)
    parts = []
    node[1][:rules].each do |rule|
        File.open("./Nodes/switch.rb", mode = "a"){|f|

            if rule[:t] == "eq" && $created_node_parts.include?(:switch_eq) == false
                parts << :switch_eq
                next
            end

            if rule[:t] == "neq" && $created_node_parts.include?(:switch_neq) == false
                parts << :switch_neq
                next
            end

            if rule[:t] == "lt" && $created_node_parts.include?(:switch_lt) == false
                parts << :switch_lt
                next
            end

            if rule[:t] == "lte" && $created_node_parts.include?(:switch_lte) == false
                parts << :switch_lte
                next
            end

            if rule[:t] == "gte" && $created_node_parts.include?(:switch_gte) == false
                parts << :switch_gte
                next
            end

            if rule[:t] == "gt" && $created_node_parts.include?(:switch_gt) == false
                parts << :switch_gt
                next
            end

        }
    end
    return parts
end

def Write_switchmain()
    File.open("./Nodes/switch.rb", mode = "a"){|f|
        f.write(Switch_main_code())
    }
end


def Switch_main_code()
    code = "
def Node_switch(node_id)
    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)
    if input_array == []
      return 0
    end

    input_array.each do |input_data|
        if input_data == \"\" 
          return 0
        end
    end
    output_flg = []
    #本機能
    #各入力データに対し、各出力点に対する条件と比較を行う。
    input_array.each do |input_data|
        count = 0
        Nodes_Hash[node_id][:rules].each do |rules_element|
    "
    if $created_node_parts.include?(:switch_eq)
        code = code + "
            if rules_element[:t] == \"eq\"
                if rules_element[:v].to_f == input_data
                    output_flg << 1
                else
                    output_flg << 0
                end
            end
        "
    end

    if $created_node_parts.include?(:switch_neq)
        code = code + "
            if rules_element[:t] == \"neq\"
                if rules_element[:v].to_f != input_data
                    output_flg << 1
                else
                    output_flg << 0
                end
            end
        "
    end

    if $created_node_parts.include?(:switch_lt)
        code = code + "
            if rules_element[:t] == \"lt\"
                if input_data < rules_element[:v].to_f
                    output_flg << 1
                else
                    output_flg << 0
                end
            end
        "
    end

    if $created_node_parts.include?(:switch_lte)
        code = code + "
            if rules_element[:t] == \"lte\"
                if input_data <= rules_element[:v].to_f
                    output_flg << 1
                else
                    output_flg << 0
                end
            end
            "
    end

    if $created_node_parts.include?(:switch_gt)
        code = code + "
            if rules_element[:t] == \"gt\"
                if input_data > rules_element[:v].to_f
                    output_flg << 1
                else
                    output_flg << 0
                end
            end
            "
    end

    if $created_node_parts.include?(:switch_gte)
        code = code + " 
            if rules_element[:t] == \"gte\"
                if input_data >= rules_element[:v].to_f
                    output_flg << 1
                else
                    output_flg << 0
                end
            end
            "
    end

    code = code + "
            count += 1
        end
    end
    Dataprocessing(node_id,:create,output_flg)
end"

    return code
end