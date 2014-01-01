require 'spec_helper'
require_relative 'base'

describe TrackSensor::MicroWizardFastTrack do
  let(:device_initialization_data) { '' }
  let(:result_data) { %Q(A=3.100! B=3.200" C=3.300# D=3.400$ E=0.000% F=0.000& \r\n) }
  let(:new_race_command) { 'RA' }
  it_behaves_like 'track sensors'
end
