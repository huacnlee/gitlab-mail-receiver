# Daemon code from: https://github.com/huacnlee/sails
module MailReceiver
  class Daemon
    class << self
      attr_accessor :options, :daemon, :mode, :app_name, :pid_file, :log_file, :runblock

      def init(opts = {}, &block)
        self.app_name = 'gitlab-mail-receiver'
        self.pid_file = File.join(opts[:root], "tmp/pids/gitlab-mail-receiver.pid")
        self.log_file = File.join(opts[:root], 'log/gitlab-mail-receiver.log')
        self.daemon = opts[:daemon]
        self.options = opts
        self.runblock = block
      end

      def read_pid
        if !File.exist?(pid_file)
          return nil
        end

        pid = File.open(pid_file).read.to_i
        begin
          Process.getpgid(pid)
        rescue
          pid = nil
        end
        pid
      end

      def start_process
        old_pid = read_pid
        if !old_pid.nil?
          puts colorize("Current have #{app_name} process in running on pid #{old_pid}", :red)
          return
        end

        # start master process
        @master_pid = fork_master_process!
        File.open(pid_file, "w+") do |f|
          f.puts @master_pid
        end

        if self.daemon
          puts "pid_file: #{self.pid_file}"
          puts "log_file: #{self.log_file}"
        end
        puts "Started #{app_name} on pid: #{@master_pid}"
        # puts "in init: #{Sails.service.object_id}"

        if not self.daemon
          Process.waitpid(@master_pid)
        else
          exit
        end
      end

      def restart_process(options = {})
        old_pid = read_pid
        if old_pid == nil
          puts colorize("#{app_name} process not found on pid #{old_pid}", :red)
          return
        end

        print "Restarting #{app_name}..."
        Process.kill("USR2", old_pid)
        puts colorize(" [OK]", :green)
      end

      def fork_master_process!
        fork do
          # WARN: DO NOT CALL Sails IN THIS BLOCK!
          $PROGRAM_NAME = self.app_name + " [master]"
          @child_pid = fork_child_process!

          Signal.trap("QUIT") do
            Process.kill("QUIT", @child_pid)
            exit
          end

          Signal.trap("USR2") do
            Process.kill("USR2", @child_pid)
          end

          loop do
            sleep 1
            begin
              Process.getpgid(@child_pid)
            rescue Errno::ESRCH
              @child_pid = fork_child_process!
            end
          end
        end
      end

      def fork_child_process!
        pid = fork do
          $PROGRAM_NAME = self.app_name + " [worker]"
          Signal.trap("QUIT") do
            exit
          end

          Signal.trap("USR2") do
            # TODO: reload Sails in current process
            exit
          end

          if self.daemon == true
            redirect_stdout
          end

          # puts "in child: #{Sails.service.object_id}"
          self.runblock.call
        end
        # http://ruby-doc.org/core-1.9.3/Process.html#detach-method
        Process.detach(pid)
        pid
      end

      def stop_process
        pid = read_pid
        if pid.nil?
          puts colorize("#{app_name} process not found, pid #{pid}", :red)
          return
        end

        print "Stoping #{app_name}..."
        begin
          Process.kill("QUIT", pid)
        ensure
          File.delete(pid_file)
        end
        puts colorize(" [OK]", :green)
      end

      private
      # Redirect stdout, stderr to log file,
      # If we not do this, stdout will block sails daemon, for example `puts`.
      def redirect_stdout
        redirect_io($stdout, self.log_file)
        redirect_io($stderr, self.log_file)
      end

      def redirect_io(io, path)
        File.open(path, 'ab') { |fp| io.reopen(fp) } if path
        io.sync = true
      end

      def colorize(text, c)
        case c
        when :red
          return ["\033[31m",text,"\033[0m"].join("")
        when :green
          return ["\033[32m",text,"\033[0m"].join("")
        when :blue
          return ["\033[34m",text,"\033[0m"].join("")
        else
          return text
        end
      end
    end
  end
end
