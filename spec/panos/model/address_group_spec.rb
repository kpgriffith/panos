require 'spec_helper'
require 'panos/models/address_group'

describe 'Address Group' do
  context 'name' do
    it 'succeeds when not nil' do
      address_group = AddressGroup.new('name', 'Static', 'criteria')
      expect(address_group).to be_a AddressGroup
    end

    it 'fails when nil' do
      expect{AddressGroup.new(nil, 'Static', 'criteria')}.to raise_error(ArgumentError)
    end
  end

  context 'type' do
    it 'fails when nil' do
      expect{AddressGroup.new('name', nil, 'criteria')}.to raise_error(ArgumentError)
    end

    it 'succeeds when valid' do
      %w(STATIC DYNAMIC).each do |type|
        address_group = AddressGroup.new('name', type, 'criteria')
        expect(address_group.type).to be == type
      end
    end

    it 'fails when not valid' do
      %w(OH_MAN FAIL).each do |type|
        expect{AddressGroup.new('name', type, 'criteria')}.to raise_error(ArgumentError)
      end
    end
  end

  context 'criteria' do
    it 'succeeds when not nil' do
      address_group = AddressGroup.new('name', 'Static', 'criteria')
      expect(address_group).to be_a AddressGroup
    end

    it 'fails when nil' do
      expect{AddressGroup.new('name', 'Static', nil)}.to raise_error(ArgumentError)
    end
  end
end
