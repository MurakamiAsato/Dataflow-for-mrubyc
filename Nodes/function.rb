#this is function Node
def FunctionNode_Nb3236(msg)
data = msg 

if data == 0
 leds_write(0)
 return 1
end

if data == 1
 leds_write(15)
 return 0
end
 
end
def FunctionNode_N3ebdb(msg)
data = msg 

if data == 0
 puts "LEDが点灯"
end

if data == 1
 puts "LEDが消灯"
end
 
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
    
        if node_id == :Nb3236
            output = FunctionNode_Nb3236(input_data)
        end
        
        if node_id == :N3ebdb
            output = FunctionNode_N3ebdb(input_data)
        end
        
    end
    Dataprocessing(node_id,:create,[output])
end
    
def Node_function(node_id)
    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)
    if input_array == []
        return 0
    end
    output = 0

    input_array.each do |input_data|
 
    
    end
    Dataprocessing(node_id,:create,[output])
end
    
def Node_function(node_id)
    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)
    if input_array == []
        return 0
    end
    output = 0

    input_array.each do |input_data|
 
    
    end
    Dataprocessing(node_id,:create,[output])
end
    