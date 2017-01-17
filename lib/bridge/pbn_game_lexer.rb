module Bridge
  class PbnGameLexer
    def self.lex(pbn_game_string)
      @@tokens = []
      pbn_game_string.each_line('\n') do |line|
        puts 'i got here: `' + line + '\''
        @@token = '' #safe: tokens explicitly cannot cross newlines
        line.split(//).each do |char|
          puts 'got here too : `' + char + '\''
          #single-character self-terminating tokens
          if char =~ /[\[\]]/
            @@token << char
            terminate
          end
        end
      end
      @@tokens
    end

    def self.terminate
      @@tokens << @@token
      @@token = ''
    end
  end
end