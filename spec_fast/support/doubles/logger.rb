# -*- encoding : utf-8 -*-

def stub_logger
  stub_const('Rails', Module.new) unless defined? Rails

  logger = double
  allow(logger).to receive(:debug).with(any_args())
  allow(logger).to receive(:info).with(any_args())
  allow(logger).to receive(:warn).with(any_args())
  allow(logger).to receive(:error).with(any_args())
  allow(logger).to receive(:fatal).with(any_args())

  allow(Rails).to receive(:logger).and_return(logger)
end
