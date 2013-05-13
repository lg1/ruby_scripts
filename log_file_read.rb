require 'fileutils'
require "Date"
file_name="G:\\log"
array_of_file_lines=IO.readlines(file_name)
destination_dir=""
cell_element=""
sample_num=""
video_num=""
month_number=""
time=""
count_specimens=0
count_gen_starts=0
amount_of_specimens=0
amount_of_gen_starts=0
amount_of_gen_stops=0
gen_is_on_flag=0
file_name_time_hash=Hash.new 
dir="G:\\test_script"
# creation of hash: name of month (e.g. "Jan" or "Nov") => number of month
month_number_hash=Hash.new
for i in 1..12
	month_number_hash[Date::MONTHNAMES[i].scan(/\A\w{3}/)[0]]=("01".."12").to_a[i-1]
end

list_of_files=Dir.entries(dir)
specimens_times_hash=Hash.new 
specimen_name=""
specimen_time_of_placing=""
specimen_time_of_replacing=""
time_of_starting_gen=""
parameters_of_generator=""
time_of_stoping_gen=""
gen_time_hash=Hash.new
#function for converting time from log files of generator to unified format of 2 times 
def convert_log_file_time(string)
	array=Array.new(2)	
	array=string.gsub(/:/,".").split("/")
	#if (array[1]!=nil or array[1]=="") then array[1]=string.split("/")[1].gsub(/:/,".") end
	return array
end
#count_specimensing the total number of starts of recordings
array_of_file_lines.each do |line|
	if line.include? "Specimen"
		amount_of_specimens=amount_of_specimens+1
	end
	if line.include? "Start_gen"
		amount_of_gen_starts=amount_of_gen_starts+1
	end	
	if line.include? "Stop_gen"
		amount_of_gen_stops=amount_of_gen_stops+1
	end
end		
puts amount_of_specimens
#creation of hash, connecting name of specimen and time of starting of recording and end of recording
for i in 0..(array_of_file_lines.length-1)	
	if array_of_file_lines[i].include? "Specimen"	
		if (count_specimens!=0 and count_specimens!=(amount_of_specimens-1))
			specimen_time_of_replacing=array_of_file_lines[i].reverse.scan(/\S{10,12}\s\S{10}/)[0].reverse
			specimens_times_hash[specimen_time_of_placing+"/"+specimen_time_of_replacing]=specimen_name	
			specimen_name=array_of_file_lines[i].reverse.sub(/\S{10,12}\s\S{10}/,"").reverse.sub(/Specimen/,"")[0..-3]
			specimen_time_of_placing=specimen_time_of_replacing
			count_specimens=count_specimens+1
		elsif (count_specimens==(amount_of_specimens-1) and amount_of_specimens!=1)
			specimen_time_of_replacing=array_of_file_lines[i].reverse.scan(/\S{10,12}\s\S{10}/)[0].reverse
			specimens_times_hash[specimen_time_of_placing+"/"+specimen_time_of_replacing]=specimen_name
			specimen_time_of_placing=specimen_time_of_replacing
			specimen_name=array_of_file_lines[i].reverse.sub(/\S{10,12}\s\S{10}/,"").reverse.sub(/Specimen/,"")[0..-3]
			specimens_times_hash[specimen_time_of_placing+"/"+""]=specimen_name
		elsif (count_specimens==0 and amount_of_specimens!=1)	
			specimen_time_of_placing=array_of_file_lines[i].reverse.scan(/\S{10,12}\s\S{10}/)[0].reverse
			specimen_name=array_of_file_lines[i].reverse.sub(/\S{10,12}\s\S{10}/,"").reverse.sub(/Specimen/,"")[0..-3]
			count_specimens=count_specimens+1
		elsif (count_specimens==0 and amount_of_specimens==1)
			specimen_time_of_placing=array_of_file_lines[i].reverse.scan(/\S{10,12}\s\S{10}/)[0].reverse
			specimen_name=array_of_file_lines[i].reverse.sub(/\S{10,12}\s\S{10}/,"").reverse.sub(/Specimen/,"")[0..-3]
			specimens_times_hash[specimen_time_of_placing+"/"+""]=specimen_name
		end	
	end	
	if array_of_file_lines[i].include? "Start_gen"
		if gen_is_on_flag==0
			time_of_starting_gen=array_of_file_lines[i].reverse.scan(/\S{10,12}\s\S{10}/)[0].reverse
			parameters_of_generator=array_of_file_lines[i].reverse.sub(/\S{10,12}\s\S{10}/,"").reverse.sub(/Start_gen/,"")
			gen_is_on_flag=1
			if ((count_gen_starts==(amount_of_gen_starts-1)) and amount_of_gen_starts!=amount_of_gen_stops)
				gen_time_hash[time_of_starting_gen+"/"]=parameters_of_generator
			end	
			count_gen_starts=count_gen_starts+1
		else
			time_of_stoping_gen=array_of_file_lines[i].reverse.scan(/\S{10,12}\s\S{10}/)[0].reverse
			gen_time_hash[time_of_starting_gen+"/"+time_of_stoping_gen]=parameters_of_generator
			time_of_starting_gen=time_of_stoping_gen
			if ((count_gen_starts==(amount_of_gen_starts-1)) and amount_of_gen_starts!=amount_of_gen_stops)
				gen_time_hash[time_of_starting_gen+"/"]=parameters_of_generator
			end
			count_gen_starts=count_gen_starts+1						
		end	
	end	
	if array_of_file_lines[i].include? "Stop_gen"
		time_of_stoping_gen=array_of_file_lines[i].reverse.scan(/\S{10,12}\s\S{10}/)[0].reverse
		gen_time_hash[time_of_starting_gen+"/"+time_of_stoping_gen]=parameters_of_generator
		gen_is_on_flag=0
	end	
end
puts count_specimens
#creation of hash with keys as time stamps and values as file names
list_of_files.each do |file_name|
	if (file_name!="." && file_name!="..")
		time=file_name.scan(/\s\w{3}\s.{16}/)[0]
		month_number=month_number_hash[time.scan(/[a-zA-Z]{3}/)[0]]
		file_name_time_hash[time.reverse[0..-6].reverse.insert(3,"."+month_number+".").gsub(/\s/,"").gsub(/_/," ")]=File.join(dir,file_name)
	end	
end	
# checks the inclusion of date of the beginning of capturing video in time range of specimen placement/displacement
def include_in_time_range?(string,array,filename)
	 
	end_of_file=string.sub(/\s/,".").split(".")
	end_of_file_time=Time.mktime(end_of_file[2],end_of_file[1],end_of_file[0],end_of_file[3],end_of_file[4],end_of_file[5])
	number_of_seconds=get_video_duration(filename)
	array_start_time_s=array[0].sub(/\s/,".").split(".")
	
	array_start_time=Time.mktime(array_start_time_s[2],array_start_time_s[1],array_start_time_s[0],array_start_time_s[3],array_start_time_s[4],array_start_time_s[5],array_start_time_s[6])
	
	if (array[1]==nil or array[1]=="") then return (end_of_file_time>=array_start_time) end
	
	array_end_time_s=array[1].sub(/\s/,".").split(".")
	array_end_time=Time.mktime(array_end_time_s[2],array_end_time_s[1],array_end_time_s[0],array_end_time_s[3],array_end_time_s[4],array_end_time_s[5],array_end_time_s[6])
	return ((((array_end_time-end_of_file_time)>=0) and (number_of_seconds>=(array_end_time-end_of_file_time))) or ((0>=(array_end_time-end_of_file_time)) and (number_of_seconds>=(end_of_file_time-array_end_time))))
end	

new_file=""
file=nil
start_end_gen=""
number_of_seconds=0
execution_output=Array.new(2) 
time_range=Array.new(2) 
array_start_time_s=Array.new(7)
time_record_start=Time.new
time_gen_start=Time.new
def get_video_duration(filename)
	new_file='"'+filename+'"'
	output=IO.popen("property_value.exe #{new_file} Delay NumberImages")
	execution_output=output.readlines
	number_of_seconds=execution_output[0][0..-2].to_f*execution_output[1][0..-2].to_f
	return number_of_seconds
end	
file_name_time_hash.keys.each do |record_time|
	new_file=file_name_time_hash[record_time]
	#FileUtils.touch(new_file+".txt")
	file=File.open(new_file[0..-5]+".txt",'w')
	number_of_seconds=get_video_duration(new_file)
	end_of_file=record_time.sub(/\s/,".").split(".")
	#puts time_array[0],time_array[1],time_array[2],time_array[3],time_array[4],time_array[5]
	#time_record_start=Time.mktime(time_array[2],time_array[1],time_array[0],time_array[3],time_array[4],time_array[5])

	gen_time_hash.keys.each do |time_interval|
		time_range=convert_log_file_time(time_interval)
		#time_array=time_range[0].sub(/\s/,".").split(".")
		#time_gen_start=Time.mktime(time_array[2],time_array[1],time_array[0],time_array[3],time_array[4],time_array[5],time_array[6])
		if (include_in_time_range?(record_time,time_range,file_name_time_hash[record_time]))
			if time_range[1]==nil
				file.write("Start_gen"+time_range[0]+" "+gen_time_hash[time_interval])
			else
				file.write("Start_gen"+time_range[0]+" "+"Stop_gen"+time_range[1]+" "+gen_time_hash[time_interval])
			end
		end		

	end
	file.close		
end
puts (time_record_start-time_gen_start)>=0, (time_record_start-time_gen_start), number_of_seconds
puts specimens_times_hash
#sorting to folders named by specimen names
file_name_time_hash.keys.each do |record_time|
	puts record_time
	specimens_times_hash.keys.each do |sample_time|
		puts convert_log_file_time(sample_time)
		if include_in_time_range?(record_time,convert_log_file_time(sample_time),file_name_time_hash[record_time])
			destination_dir=dir+"/"+specimens_times_hash[sample_time]
			if File.directory?(destination_dir)==false then FileUtils.mkdir(destination_dir) end	
			FileUtils.mv(file_name_time_hash[record_time],destination_dir)
			FileUtils.mv(file_name_time_hash[record_time][0..-5]+".txt",destination_dir)
			break
		end	
	end
end		
puts gen_time_hash	
#puts (number_of_seconds>=(time_gen_start-time_record_start)), number_of_seconds, execution_output, new_file