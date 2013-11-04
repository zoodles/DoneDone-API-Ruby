require 'spec_helper'

describe DoneDone::Http do
  class BogusNetHttp
    attr_reader :host, :port, :use_ssl
    attr_accessor :ssl_version, :verify_mode
    def initialize(host, port)
      @host = host
      @port = port
      clear
    end

    def clear
      @use_ssl = false
      @verify_mode = nil
      @ssl_version = nil
    end

    def use_ssl=(bool)
      @use_ssl = !!bool
    end

    def request(request_object)
      @request = request_object
    end
  end

  let(:net_http_class) { BogusNetHttp }
  let(:domain) { "domain" }
  let(:username) { "username" }
  let(:password) { "password" }
  let(:new_options) { {:http_class => net_http_class} }
  let(:new_args) { [domain, username, password, new_options] }
  let(:donedone_http_object) { DoneDone::Http.new(*new_args) }
  let(:request_methods) { [:get, :put, :post] }

  describe "init" do
    context 'invalid args' do
      it "raises an Exception for 0-2 args" do
        expect { DoneDone::Http.new }.to raise_error()
        expect { DoneDone::Http.new(domain) }.to raise_error()
        expect { DoneDone::Http.new(domain, username) }.to raise_error()
      end
      it "raises an Exception for >4 args" do
        expect { DoneDone::Http.new(domain, username, password, {}, :extra1) }.to raise_error()
      end
    end

    context 'valid args' do
      it "requires 3-4 args" do
        expect { DoneDone::Http.new(domain, username, password) }.to_not raise_error()
        expect { DoneDone::Http.new(domain, username, password, {}) }.to_not raise_error()
      end
    end
  end

  describe "request(s)" do
    let(:method_url) { "method_url" }

    context 'invalid args' do
      it "will raise an Exception for 0 args" do
        request_methods.each do |method|
          expect { donedone_http_object.send(method) }.to raise_error
        end
      end
      it "will raise an Exception for >2 args" do
        request_methods.each do |method|
          expect { donedone_http_object.send(method, method_url, {}, :extra1) }.to raise_error
        end
      end
    end
    context 'valid args' do
      let(:ssl_port) { 443 }
      it "will not raise an Exception for 1-2 args" do
        request_methods.each do |method|
          expect { donedone_http_object.send(method, method_url) }.to_not raise_error
          expect { donedone_http_object.send(method, method_url, {}) }.to_not raise_error
        end
      end

      # a bit fragile: specific to Net::HTTP
      it "sets-up a proper http object for :get" do
        expect(donedone_http_object.host).to start_with(domain)
        net_http_obj = net_http_class.new(donedone_http_object.host, ssl_port)
        net_http_class.should_receive(:new).exactly(request_methods.length).times.with(donedone_http_object.host, ssl_port).and_return(net_http_obj)

        request_methods.each do |method|
          expect(net_http_obj.use_ssl).to eq(false)
          expect(net_http_obj.verify_mode).to eq(nil)
          expect(net_http_obj.ssl_version).to eq(nil)
          donedone_http_object.send(method, method_url)
          expect(net_http_obj.use_ssl).to eq(true)
          expect(net_http_obj.verify_mode).to eq(DoneDone::Constant::SSL_VERIFY_MODE)
          expect(net_http_obj.ssl_version).to eq(DoneDone::Constant::SSL_VERSION)
          donedone_http_object.reset
          net_http_obj.clear
        end
      end
    end
  end
end
