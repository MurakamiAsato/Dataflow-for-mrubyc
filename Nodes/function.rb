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
    