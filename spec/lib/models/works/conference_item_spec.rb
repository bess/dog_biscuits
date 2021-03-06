# frozen_string_literal: true

require 'spec_helper'

describe DogBiscuits::ConferenceItem do
  let(:stubby) { FactoryBot.build(:conference_item) }
  let(:rdf) { stubby.resource.dump(:ttl) }
  let(:solr_doc) { SolrDocument.new(stubby.to_solr) }

  after do
    stubby.destroy
  end

  it 'is a conference item' do
    expect(stubby).to be_conference_item
  end

  # Concerns
  it_behaves_like 'editor'
  it_behaves_like 'event_date'
  it_behaves_like 'location'
  it_behaves_like 'presented_at'

  describe '#rdftypes' do
    specify { stubby.type.should include('http://london.ac.uk/ontologies/terms#ConferenceItem') }
    specify { stubby.type.should_not include('https://bib.schema.org/Thesis') }
  end

  describe 'combine dates' do
    before do
      stubby.combine_dates
    end
    specify { stubby.date.should eq(%w[2016 2015 2013 2014]) }
  end

  describe '#predicates' do
    specify { rdf.should include('http://purl.org/dc/terms/date') }
  end
end
