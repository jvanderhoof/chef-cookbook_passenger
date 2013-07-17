define :rack_app, :template => "rack_app.conf.erb", :enable => true do

  application_name = params[:name]

  template "#{node['apache']['dir']}/sites-available/#{application_name}.conf" do
    source params[:template]
    owner "root"
    group node['apache']['root_group']
    mode 0644
    #if params[:cookbook]
    #  cookbook params[:cookbook]
    #end
    variables(
      :application_name => application_name,
      :params => params
    )
    if ::File.exists?("#{node['apache']['dir']}/sites-enabled/#{application_name}.conf")
      notifies :reload, resources(:service => "apache2"), :delayed
    end
  end

  site_enabled = params[:enable]
  apache_site "#{params[:name]}.conf" do
    enable site_enabled
  end
end
