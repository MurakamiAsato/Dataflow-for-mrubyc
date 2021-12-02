def Function_initialize()
    #ノード群のデータ書き込み&ノード管理の実装&バッファーの実装

    File.open("./Nodes/function.rb", mode = "w"){|f|
    f.write("#this is function Node\n")  # ファイルに書き込む
    }
end

def Write_function(node_id,func)
    node_id = node_id.to_s()
    File.open("./Nodes/function.rb", mode = "a"){|f|
    f.write("def FunctionNode_"+ node_id + "(msg)\n")
    f.write(func)  # ファイルに書き込む
    f.write("\n")
    f.write("end\n")
    }

end

#存在しているfunctionノードの管理・実行を行うためのmain関数
def Write_Mainfunction(node_ids)
    File.open("./Nodes/function.rb", mode = "a"){|f|
    #### -- main --#####
    f.write("
def Node_function(node_id)
    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)
    if input_array == []
        return 0
    end
    output = 0

    input_array.each do |input_data|
 
    ")

    node_ids.each do |node_id|
        node_id = node_id.to_s()
        f.write("
        if node_id == :" + node_id + "
            output = FunctionNode_"+ node_id + "(input_data)
        end
        ")
    end

    f.write("
    end
    Dataprocessing(node_id,:create,[output])
end
    ")
    ### -- end -- ######
    }

end
