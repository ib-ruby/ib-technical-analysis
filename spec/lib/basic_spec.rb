require 'spec_helper'
require 'main_helper'

## check if the TWS is attached properly 
##
## check if the sample data are present

RSpec.describe IB::Gateway do
  #before(:all){ establish_connection }
  before(:all){ init_gateway }

  context "test connection" do
    it { expect( IB::Connection.current).to be_a IB::Connection }
  end
end


RSpec.describe "Sample Files"  do
  context "Files are in proper path" do
    subject {  read_sample_data }

    it { is_expected.to be_a Array }
    its( :size ){ is_expected.to  eq 43 }

    it "contains proper Objects" do
      subject.each{ |y| expect( y ).to be_a IB::Bar }
    end
  end
end
