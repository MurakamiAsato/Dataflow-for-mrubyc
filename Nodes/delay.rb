def Node_delay(node_id)
    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)  
    if input_array == [] && Nodes_Hash[node_id][:depo_data] == ""
      return 0
    end
    if Nodes_Hash[node_id][:depo_data] == ""
        Nodes_Hash[node_id][:depo_data] = input_array
        Nodes_Hash[node_id][:last_time] =  VM.tick()/1000.0
    end
    if GetTime(node_id) == 1
        input_array = Nodes_Hash[node_id][:depo_data]
        Nodes_Hash[node_id][:depo_data] = ""
        output = 0
        input_array.each do |input|
            output = input
        end
        Dataprocessing(node_id,:create,[output]) 
    end
end