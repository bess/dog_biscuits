# frozen_string_literal: true

require 'spec_helper'

describe DogBiscuits::Terms::PlacesTerms do
  let(:terms) { described_class.new('places') }

  it 'has no terms' do
    terms.all.should eq([])
  end

  let(:place) { FactoryGirl.create(:place) }
  let(:places) { FactoryGirl.create(:places) }

  it 'has one term' do
    places.places << place
    terms.all.length.should eq(1)
  end

  it 'has term hash' do
    places.places << place
    terms.all.should eq([{ id: place.id.to_s, label: "Didsbury, Madeup Parish, Manchester, Greater Manchester, England, United Kingdom" }])
  end

  it 'does not find the term by id' do
    places.places << place
    terms.find('not-a-real-id').should eq([])
  end

  it 'finds the term by id' do
    places.places << place
    terms.find(place.id).first[:label].should eq('Didsbury, Madeup Parish, Manchester, Greater Manchester, England, United Kingdom')
  end

  it 'returns one result' do
    places.places << place
    terms.search('Manchester').length.should eq(1)
  end

  it 'returns no results' do
    places.places << place
    terms.search('fake search').length.should eq(0)
  end

  it 'finds the id by the label' do
    places.places << place
    terms.find_id('Didsbury, Madeup Parish, Manchester, Greater Manchester, England, United Kingdom').should eq(place.id)
  end

  it 'finds the label by the id' do
    places.places << place
    terms.find_value_string(place.id).should eq(['Didsbury, Madeup Parish, Manchester, Greater Manchester, England, United Kingdom'])
  end

  it 'returns all for options list' do
    places.places << place
    terms.select_all_options.should eq([["Didsbury, Madeup Parish, Manchester, Greater Manchester, England, United Kingdom", place.id.to_s]])
  end
end