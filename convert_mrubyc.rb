#オプションの付与
require 'optparse'

#winで動かす時用のエンコーディング形式の明示
Encoding.default_external = 'utf-8'

require 'fileutils'

#コンパイル&転送するプログラム名
$file_name = ""

#mrbcおよびmrbwriteのあるディレクトリ
$mrubycompiler_folder = "./mrubyc_ide1.02_win"

$Device_Name = "RBoard"

$Auto_Run_Flag = false #生成されたプログラムをすぐにデバイスに流し込むか(RBoard用)
$Poat_Num = "COM6" #RBoardをUSB接続したときのポート番号

$error_flag = false

def Read_filename()
  option = {}
  OptionParser.new do |opt|
    opt.on('-r Filename',   '読み込む.rbファイル名を指定') {|name| option[:r] = name}
    opt.parse!(ARGV)
  end

  if option[:r] != nil
    mrubyc_program = option[:r]
  else
    puts "---.rbファイルを入力してください---"
    filenames = Dir.open("createdRuby",&:to_a)
    filenames.each do |filename|

    
      if filename.include?(".rb") == true
        p filename
      end
    end
    mrubyc_program = gets().chomp()
  end

  $file_name = mrubyc_program.gsub(/.rb/,"")

end

puts 
def Compile_to_mrb(file_name)
  puts "---指定したRubyコードを.mrbにコンパイルします。---"
  #puts "#{$mrubycompiler_folder}/mrbc #{file_name}.rb"
  system("#{$mrubycompiler_folder}/mrbc ./createdRuby/#{file_name}.rb")

  #コンパイルの成功の確認
  $error_flag = true
  filenames = Dir.open("createdRuby",&:to_a)
  filenames.each do |filename|
    if filename == "#{file_name}.mrb"
      $error_flag = false
      puts "コンパイル成功"
      break
    end
  end

end


#生成したプログラムをデバイスに流し込む（RBoard用）
def Pouting_program_to_device(filename)

  if $error_flag == true
    puts "コンパイル失敗"
    return 0
  end

  if $Auto_Run_Flag == false
    puts "Q. 生成した.mrbコードを「#{$Device_Name}」で実行しますか？"
    puts "yes 　or   no"
    answer = gets

    if answer.include?("y") != true
      return
    end
  end

  #puts file_name
  puts "---書き込みを開始します。リセットボタンを押してください---"
  begin
    #puts "#{$mrubycompiler_folder}/mrbwrite -l  #{$Poat_Num} -s 19200 #{filename}.mrb"
    system("#{$mrubycompiler_folder}/mrbwrite -l  #{$Poat_Num} -s 19200  ./createdRuby/#{filename}.mrb")
    # puts "system出力終了"
  rescue => err
    puts "「#{$Device_Name}」にてmrubycコード実行中にエラーが起きました。"
    puts err
    puts "------------"
  end


end

##########以下main文###################
Read_filename()
Compile_to_mrb($file_name)
Pouting_program_to_device($file_name)