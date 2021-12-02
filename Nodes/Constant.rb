def Node_Constant(node_id)
  input_array = Dataprocessing(node_id,:get)
  Dataprocessing(node_id,:delete)
  if input_array == []
    return 
  end
  Dataprocessing(node_id,:create,[Nodes_Hash[node_id][:C].to_i])  
end