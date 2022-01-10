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