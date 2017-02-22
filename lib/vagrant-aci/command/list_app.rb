module VagrantPlugins
  module ACI
    module Command
      class List < Vagrant.plugin("2", :command)
       def self.synopsis
          "List deployed ACI Application Network Profiles"
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
	            
	            o.banner = "Usage: vagrant aci app list [options]"
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
				  o.on("-n n", "--name", "Application name") do |n|
				    options[:name] = n
				    appName = options[:name]
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
			    	listANP(ip,appName,tenant,token)
			   	end
			end

         	0
				
        	end

    	end

        def listANP(ip,appName,tenant,token)
        	
			begin

				if appName.nil?
					encoded = URI.encode("https://#{ip}/api/node/mo/uni/tn-#{tenant}.json?query-target=subtree&target-subtree-class=fvAp");      

					response = JSON.parse(RestClient::Request.execute(
						:method => :get,
						:url => encoded,
						:verify_ssl => false,
						:content_type => "application/json",
						:accept => "application/json",
						:cookies => {"APIC-Cookie" => "#{token}"}
					));	

					 apps = response["imdata"]
					 	
						 # build table with data returned from above function
						
						table = Text::Table.new
						table.head = ["Application Name"]
						puts "\n"
					
						#for each item in returned list, display certain attributes in the table
						apps.each do |row|
							appName = row["fvAp"]["attributes"]["name"]
							table.rows << ["#{appName}"]
						end
					
						puts table
						
						puts"\n"
				elsif 
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
	
						vmm = response["imdata"][0]["fvRsDomAtt"]["attributes"]["dn"]
						
						epg = vmm.match(/\/epg-(.*?)[\/]/)
						epg = epg[0]
						epg = epg[5..epg.length-2]
						if vmm.match(/vmmp-VMware/)
							puts "\n"
							puts "Application Summary: #{appName} "
							puts "--------------------------------"
							puts "Tenant: #{tenant} \n"
							puts "Application Name: #{appName} \n"
							puts "Endpoint Group: #{epg} \n\n"
							puts "VMWare Portgroup: #{tenant}|#{appName}|#{epg} \n\n"
						end
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