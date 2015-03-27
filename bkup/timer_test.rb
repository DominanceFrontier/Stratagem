cmd = "python /home/student/Desktop/Ujjwal/Stratagem/runner.py /home/student/Desktop/Ujjwal/Stratagem get_move \"[[\\\"X\\\",\\\"O\\\",\\\"X\\\"],[\\\"O\\\",\\\"O\\\",\\\"X\\\"],[\\\"X\\\",\\\" \\\",\\\"O\\\"]]\""
r, w = IO.pipe
pid = spawn(cmd, out: w)
start_time = Process.times
Process.wait pid
w.close
move = r.read
r.close
if move
  p ["success!", move]
else
  p ["failure!", "timed out?"]
end
end_time = Process.times
p start_time
p end_time
total_time = end_time.cutime - start_time.cutime + end_time.cstime - start_time.cstime
puts (total_time * 1000).to_i
  
