module VagrantPlugins
  module ACI
    module Command
      class New < Vagrant.plugin("2", :command)
       def self.synopsis
          "Add an ACI Application Network Profile"
        end

        def execute

          	username = ""
          	password = ""
          	tenant = ""
          	appName = ""
          	ip = ""
          	anp = ""

          	username = ENV["aci_username"]
            password = ENV["aci_password"]
            tenant = ENV["aci_tenant"]
			appName = ENV["aci_app_name"]
            ip = ENV["aci_ip"]
            anp = ENV["aci_anp"]

            options = {}
	          opts = OptionParser.new do |o|
	            
	            o.banner = "Usage: vagrant aci app new [options]"
	            o.separator ""

				  o.on("-t n", "--tenant", "ACI tenant name") do |n|
				    options[:tenant] = n
				    tenant = options[:tenant]
				  end
				  o.on("-i n", "--ip", "IP address of ACI Controller") do |n|
				    options[:ip] = n
				    ip = options[:ip]
				  end
				  o.on("-u n", "--username", "ACI Controller username") do |n|
				    options[:username] = n
				    username = options[:username]
				  end
				  o.on("-n n", "--name", "Name of new application") do |n|
				    options[:name] = n
				    appName = options[:name]
				  end
				  o.on("-p n", "--path", "Path and filename for the application policy configuration file (.json)") do |n|
				    options[:path] = n
				    anp = options[:path]
				  end
				  o.on("-h n", "--help", "Print this help") do |n|
				    options[:help] = n
				    puts o.help
				  end
	          end

	        argv = parse_options(opts)
	      		        
	        if !options[:help]
	        	if !options[:ip]
					ip = ask("ACI URL or IP  ") 
				end
		        if !options[:username]
					 username = ask("ACI username:  ") 
				end
				if password.nil?
					password = ask("ACI password:  ") { |q| q.echo = false  }
				end
				if !options[:tenant]
					tenant = ask("ACI tenant:  ") 
				end
				if !options[:name]
					appName = ask("Application name:  ") 
				end
				if !options[:path]
					anp = ask("Path and filename for the Application Network Profile config file (.json)  ") 
				end

		        if !(username.nil?  or password.nil? or ip.nil?)
	          		begin

						encoded = URI.encode("https://#{ip}/api/aaaLogin.json");           
			            
						tmp = "{
						  \"aaaUser\" : {
						    \"attributes\" : {
						      \"name\" : \"#{username}\",
						      \"pwd\" : \"#{password}\"
						    }
						  }
						}"

						tmp = JSON.parse(tmp).to_json 


			            response = JSON.parse(RestClient::Request.execute(
			   					:method => :post,
			  					:url => encoded,
			                    :verify_ssl => false,
			                    :content_type => "json",
			                    :accept => "json",
			                    :payload => tmp
						));

			            token = response["imdata"][0]["aaaLogin"]["attributes"]["token"]
			    end

			    if token
			    	addANP(ip,appName,anp,tenant,token)
			   	end
			end

         	0
				
        	end

    	end

        def addANP(ip,appName,anp,tenant,token)
        	
			begin

				app_net_profile = File.read(anp)

				tmp = JSON.parse(app_net_profile)

				tmp['fvAp']['attributes']['dn'] = "uni/tn-#{tenant}/ap-#{appName}"
				tmp['fvAp']['attributes']['name'] = "#{appName}"

				tmp = tmp.to_json

				encoded = URI.encode("https://#{ip}/api/node/mo/uni/tn-#{tenant}/ap-#{appName}.json");      

				response = JSON.parse(RestClient::Request.execute(
					:method => :post,
					:url => encoded,
					:verify_ssl => false,
					:content_type => "application/json",
					:accept => "application/json",
					:payload => tmp,
					:cookies => {"APIC-Cookie" => "#{token}"}
				));	

				encoded = URI.encode("https://#{ip}/api/node/mo/uni/tn-#{tenant}/ap-#{appName}.json?query-target=subtree&target-subtree-class=fvRsDomAtt");      

				response = JSON.parse(RestClient::Request.execute(
					:method => :get,
					:url => encoded,
					:verify_ssl => false,
					:content_type => "application/json",
					:accept => "application/json",
					:cookies => {"APIC-Cookie" => "#{token}"}
				));	

			
				if response["totalCount"] != 0
					
					puts "\nApplicaton Network Profile deployed \n\n"

					
					vmm = response["imdata"][0]["fvRsDomAtt"]["attributes"]["dn"]
					
					epg = vmm.match(/\/epg-(.*?)[\/]/)
					epg = epg[0]
					epg = epg[5..epg.length-2]
					if vmm.match(/vmmp-VMware/)
						puts "Please use the following VMWare portgroup: #{tenant}|#{appName}|#{epg} \n\n"
					end
				end

	          	rescue => e

					puts e.inspect
		        
				end	

				0
        end




      end
    end
  end
end