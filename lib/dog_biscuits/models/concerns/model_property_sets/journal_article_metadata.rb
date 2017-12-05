# frozen_string_literal: true

module DogBiscuits
  # add journal article metadata
  module JournalArticleMetadata
    extend ActiveSupport::Concern
    include DogBiscuits::Abstract
    include DogBiscuits::Available
    include DogBiscuits::DatePublished
    include DogBiscuits::DateSubmitted
    include DogBiscuits::DateAccepted
    include DogBiscuits::IssueNumber
    include DogBiscuits::ManagingOrganisation
    include DogBiscuits::OfficialUrl
    include DogBiscuits::Orcid
    include DogBiscuits::Pagination
    include DogBiscuits::PartOf
    include DogBiscuits::ProjectOutput
    include DogBiscuits::PublicationStatus
    include DogBiscuits::Refereed
    include DogBiscuits::VolumeNumber
    # Controlled Properties must go last
    include DogBiscuits::CommonMetadata
  end
end