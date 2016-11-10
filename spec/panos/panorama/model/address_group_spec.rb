require 'spec_helper'
require 'panos/panorama/models/address_group'

include Panos::Panorama

describe 'Address Group' do

  it 'succeeds when all is good' do
    address_group = AddressGroup.new('name', 'Static', 'criteria', 'group', 'tag')
    expect{address_group}.to be_a AddressGroup
  end

  context 'name' do
    it 'fails when nil' do
      expect{AddressGroup.new(nil, 'Dynamic', 'criteria', 'group', 'tag')}.to raise_error(ArgumentError)
    end
  end

  context 'type' do
    it 'fails when nil' do
      expect{AddressGroup.new('name', nil, 'criteria', 'group', 'tag')}.to raise_error(ArgumentError)
    end

    it 'fails when not valid' do
      %w(OH_MAN FAIL).each do |type|
        expect{AddressGroup.new('name', type, 'criteria', 'group', 'tag')}.to raise_error(ArgumentError)
      end
    end
  end

  context 'criteria' do
    it 'fails when nil' do
      expect{AddressGroup.new('name', 'Static', nil, 'group', 'tag')}.to raise_error(ArgumentError)
    end
  end

  context 'device groups' do
    it 'fails when nil' do
      expect{AddressGroup.new('name', 'Static', 'criteria', nil, 'tag')}.to raise_error(ArgumentError)
    end
  end
end
