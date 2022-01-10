/---Buttuoノードのノードプログラム---/
def Node_Button(node_id)
  input_array = Dataprocessing(node_id,:get)
  if input_array == []
    return 0
  end
  Dataprocessing(node_id,:delete)  

  input = 0

  input_array.each do |input_data|
    if input_data != 1
      Dataprocessing(node_id,:create,[0])
      return 0
    end
  end
  /本機能/
  if Nodes_Hash[node_id][:onBoardButton] == "1"
    input = sw()
    if input == 1
      input = 0
    else
      input = 1
    end
  else
    input = digitalRead(Nodes_Hash[node_id][:targetPort].to_i)
  end

  Dataprocessing(node_id,:create,[input])
end