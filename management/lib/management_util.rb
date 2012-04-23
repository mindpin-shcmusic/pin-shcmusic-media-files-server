class ManagementUtil
  def self.check_process_by_pid_file(pid_file_path)
    return "关闭" if !File.exist?(pid_file_path)
    res = `ps \`cat #{pid_file_path}\``
    res_lines = res.split("\n")
    return "关闭" if res_lines.count == 1
    parse_ps_line(res_lines[1])
  end

  def self.parse_ps_line(line)
    stat = line.split(" ")[2]
    return "状态异常" if %w(Z T).include?(stat)
    "正常运行"
  end

  def self.log_file_content(log_path,line=1000)
    `tail -#{line} #{log_path}`
  end

  def self.get_pid_count_by_pid_file(pid_file_path)
    return nil if !File.exist?(pid_file_path)
    `cat #{pid_file_path}`
  end
end
