#ssh -L 8888:10.10.24.118:80 odchazel@ufallab.ms.mff.cuni.cz

require "json"
require "digest/sha2"
require "tempfile"

class Anotation

	def initialize(rules)

		if system("which yap > /dev/null 2>&1")
			@prolog = "yap"
		else
			@prolog = "swipl"
		end

		@words_to_i = {}
		@i_to_words = {}
		@i = 1
		@rules = JSON.parse(rules)
	end

	def get_token(word)
		if @words_to_i[word]
			return "t_" + @words_to_i[word].to_s
		else
			@words_to_i[word] = @i
			@i_to_words[@i] = word
			@i += 1
			return "t_#{@i - 1}"
		end
	end

	def convert_array(a)
		ret = "["
		a.each_with_index do |s, i|
			ret += ", " unless i == 0
			if s.class == Array
				ret += convert_array(s)
			else
				ret += convert_word(s)
			end
		end
		ret += "]"
		return ret
	end

	def convert_word(w)
		w = w.to_s
		return get_token(w)
	end

	def get_query(include_maping = false)
		ret = "sent("
		ret += convert_word(@rules['root'])
		ret += ", "
		ret += convert_array(@rules['source'])
		ret += ").\n"
		get_options.each do |option|
			ret += "\n" + option
		end

		if include_maping
			ret += "\n\n"
			ret += "%Strings maping"
			@i_to_words.each do |i|
				ret += "\n%t_#{i[0]} \t#{i[1]}"
			end

			ret += "\n\n%Source words\n"
			@rules['words'].each do |word|
				ret += "%#{word}\n"
			end
			ret += "\n\n"
		end

		return ret
	end

	def prepare_options
		change = true
		rules = @rules['options'].clone
		while change
			change = false
			new_rules = []
			rules.each do |rule|
				#puts rule
				currently_found = false
				found_index = false
				rule['target'].each_with_index do |target, i|
					if target.class == String and target.include? "\n" and change == false
						#puts " - #{target}"
						currently_found = true
						found_index = i
						change = true
					end
				end
				unless currently_found
					new_rules.push(rule)
				else
					#puts "FOUND INDEX #{found_index}"
					splited_rules = []
					rule['target'][found_index].split("\n").each do |t|
						#puts t
						r = rule.clone
						r['target'] = rule['target'].clone
						r['target'][found_index] = t
						new_rules.push(r)
					end
				end
			end
			rules = new_rules
		end
		@rules['options'] = rules
	end

	def get_options
		prepare_options
		ret = []
		@rules['options'].each do |option|
			ret.push(get_option(option))
		end
		return ret
	end

	def get_option(o)
		ret = "option("
		ret += convert_array(o['covered'])
		ret += ", "
		ret += convert_array(o['up_rules'])
		ret += ", "
		ret += convert_array(o['target'])
		ret += ")."
		return ret
	end

	def construct_prolog_string(include_maping = false)
		skeleton = File.readlines("skeleton.pl").join("")
		skeleton += "\n"
		skeleton += get_query(include_maping)
		skeleton += "\n:- demo; halt."
		return skeleton
	end

	def get_result
		str = construct_prolog_string
		hash = Digest::SHA2.new << "#{str}-#{Time.now.to_s}"
		file = File.new("/tmp/" + hash.to_s, "w")
		begin
			file.write(str)
			path = File.expand_path(file.path)
			file.close
			`#{@prolog} -l #{path} > #{path}_out`
			result = File.readlines("#{path}_out")
			File.delete(path)
			File.delete(path+"_out")
		end
		ret_words = []
		result.each do |l|
			l.chop!
			words = l[1, (l.length - 2)].split(",")
			words.map! { |w|  @i_to_words[w[2, w.length].to_i]}
			#puts words.join " "
			ret_words.push(words)
		end
		ret_words.sort!.uniq!
		request_result = {}
		request_result["words"] = ret_words
		request_result["added"] = (ret_words - @rules["last_result"]).sort!
		request_result["removed"] = (@rules["last_result"] - ret_words).sort!
		return request_result.to_json
	end

end

s = <<-STR
	{
		"source": ["hello", "world"],
		"root": "hello",
		"last_result": [],
		"options":
			[
				{
					"covered": ["hello"],
					"up_rules": ["pl"],
					"target": ["ahoj", []]
				},
				{
					"covered": ["world"],
					"up_rules": ["pl"],
					"target": ["svete\\ncesko"]
				},
				{
					"covered": ["world"],
					"up_rules": ["pl"],
					"target": ["sveticku"]
				}
			]
	}
STR

#puts Anotation.new(s).get_result()
