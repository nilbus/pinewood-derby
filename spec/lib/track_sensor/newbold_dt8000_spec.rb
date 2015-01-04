require 'spec_helper'
require_relative 'base_spec'

describe TrackSensor::NewboldDt8000 do
  let(:device_initialization_data) { "\000DT.000  NewBold Products\n" }
  let(:result_data) { "1 3.1000 2 3.2000 3 3.3000 4 3.4000\n" }
  let(:new_race_command) { ' ' }
  it_behaves_like 'track sensors'
end
