# -*- encoding : utf-8 -*-

def double_setting(key, value)
  stub_const('Admin', Module.new) unless defined? Admin
  stub_const('Admin::Setting', Class.new) unless defined? Admin::Setting

  allow(Admin::Setting).to receive(key.to_sym).and_return(value)
end
