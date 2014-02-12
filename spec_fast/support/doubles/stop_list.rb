# -*- encoding : utf-8 -*-

def double_stop_list
  double(list: 'a the', language: 'en')
end

def stub_stop_list
  stub_const('Documents::StopList', Class.new)
  allow(Documents::StopList).to receive(:find).and_return(double_stop_list)
end
