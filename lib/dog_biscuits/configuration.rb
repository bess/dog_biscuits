# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/ClassLength

module DogBiscuits
  class Configuration
    include PropertyMappings

    # All available properties
    def all_properties
      props = selected_models.map { |m| send("#{m.underscore}_properties") }.flatten
      props.concat(facet_properties)
      props.concat(index_properties)
      props << :date_range if date_range == true
      props.sort.uniq!
    end

    # All available models
    def available_models
      ['ConferenceItem',
       'Dataset',
       'DigitalArchivalObject',
       'ExamPaper',
       'JournalArticle',
       'Image',
       'Package',
       'PublishedWork',
       'Thesis',
       'InformationSheet',
       'ArchivalResource'].freeze
    end

    # Models used in the app (used by the generate_all generator)
    attr_writer :selected_models
    def selected_models
      @selected_models ||= available_models
    end

    attr_writer :date_picker
    def date_picker
      @date_picker ||= false
    end

    attr_writer :date_picker_dates
    def date_picker_dates
      @date_picker_dates ||= date_properties
    end

    attr_writer :date_range
    def date_range
      @date_range ||= false
    end

    # Default required properties.
    def required_properties
      %i[title creator keyword rights_statement].freeze
    end

    # Basic Metadata properties from Hyrax
    # Omitting bibliographic_citation
    def base_properties
      %i[title
         creator
         contributor
         description
         keyword
         license
         rights_statement
         publisher
         date_created
         subject
         language
         identifier
         based_near
         related_url
         resource_type
         source].freeze
    end

    # Common properties from DogBiscuits atop those in BasicMetadata
    # Also include resource_type which is part of BasicMetadata but not part of the Hyrax WorkForm
    # Omitting date as this is used for faceting only
    def common_properties
      %i[department doi former_identifier note output_of lat long alt location managing_organisation funder].freeze
    end

    # Add values that aren't found in the following table-based authorities to be added on save.
    #   This only works in cases where the name of the authority is a pluralized form of
    #   the name of the property which uses it, eg. subjects/subject and languages/language
    attr_writer :authorities_add_new
    def authorities_add_new
      @authorities_add_new ||= []
    end

    # All solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #   The properties must have been indexed as facetable
    # The existing fields will be replaced:
    #   resource_type, creator, tag, subject, language, based_near_label, publisher, file_format
    attr_writer :facet_properties
    def facet_properties
      @facet_properties ||= %i[
        human_readable_type
        resource_type
        creator
        contributor_combined
        contributor_type
        publisher
        department
        funder
        date
        keyword
        subject
        language
        based_near_label
        part_of
        qualification_level
        qualification_name
        refereed
        publication_status
        content_version
        packaged_by_titles
        in_archival_resource_titles
      ]
    end

    # Fields that are not included in the form or show,
    #   eg. those that are generated by the solr indexer for facets only
    #   these are already included in facet_properties
    attr_writer :facet_only_properties
    def facet_only_properties
      @facet_only_properties ||= %i[
        contributor_combined
        contributor_type
        date
        human_readable_type
        packaged_by_titles
        in_archival_resource_titles
      ]
    end

    # *All* solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    # The existing fields will be replaced so must be included here:
    #   title, description, tag, subject, creator, contributor, publisher, based_near_label, language,
    #   date_uploaded, date_modified, date_created, rights, resource_type, format, identifier, extent
    #   embargo_release_date, lease_expiration_date
    attr_writer :index_properties
    def index_properties
      @index_properties ||= %i[
        title
        creator
        publisher
        contributor_combined
        date
        keyword
        subject
        resource_type
        rights_statement
        license
        language
        depositor
        proxy_depositor
        embargo_release_date
        lease_expiration_date
      ]
    end

    attr_writer :exclude_from_search_properties
    def exclude_from_search_properties
      @exclude_from_search_properties ||= %i[
        last_access
        number_of_downloads
        aip_current_path
        dip_current_path
        aip_current_location
        dip_current_location
        aip_resource_uri
        dip_resource_uri
        packaged_by_ids
        in_archival_resource_ids
      ]
    end

    # Render these properties as singular in the form
    attr_writer :singular_properties
    def singular_properties
      @singular_properties ||= %i[
        date_accepted
        date_available
        date_created
        date_collected
        date_copyrighted
        date_issued
        date_published
        date_submitted
        date_updated
        date_valid
        end_date
        event_date
        issue_number
        pagination
        publication_status
        refereed
        release_date
        start_date
        volume_number
        aip_uuid
        transfer_uuid
        sip_uuid
        dip_uuid
        aip_status
        dip_status
        aip_size
        dip_size
        aip_current_path
        dip_current_path
        aip_current_location
        dip_current_location
        aip_resource_uri
        dip_resource_uri
        origin_pipeline
        last_access
        number_of_downloads
      ]
    end

    # All of these are date properties
    # These will be indexed into the date_picker if present
    attr_writer :date_properties
    def date_properties
      @date_properties ||= %i[
        date_accepted
        date_available
        date_collected
        date_copyrighted
        date_created
        date_issued
        date_published
        date_submitted
        date_updated
        date_valid
        date_of_award
        event_date
        release_date
        start_date
        end_date
      ]
    end

    # Enable restricted properties in the form.
    # If set to false, no restrictions will be applied
    # Default is false
    attr_writer :restricted_properties_enabled
    def restricted_properties_enabled
      @restricted_properties_enabled ||= false
    end

    # Restrict the following properties in the form to the role specified in
    #   restricted_role
    # Restrictions apply to 'below the fold' properties only, they are not
    #   applied to required properties
    # Restrictions apply in the form only, properties are still visible in the
    #   show page
    # Default is none
    attr_writer :restricted_properties
    def restricted_properties
      @restricted_properties ||= %i[last_access number_of_downloads]
    end

    # Role to use when restricting properties
    # Default is :admin
    attr_writer :restricted_role
    def restricted_role
      @restricted_role ||= :admin
    end

    # ConferenceItem

    # Properties in order:
    #   basic metadata (as per Hyrax),
    #   this model (alphebetized),
    #   remaining common properties and resource_type (alphebeized)
    attr_writer :conference_item_properties

    def conference_item_properties
      properties = %i[abstract
                      date_published
                      date_available
                      date_accepted
                      date_submitted
                      editor
                      event_date
                      isbn
                      official_url
                      pagination
                      place_of_publication
                      publication_status
                      presented_at
                      part_of
                      refereed]
      properties = base_properties + properties + common_properties
      properties.sort!
      @conference_item_properties ||= properties
    end

    attr_writer :conference_item_properties_required

    def conference_item_properties_required
      @conference_item_properties_required ||= required_properties
    end

    # DigitalArchivalObject

    attr_writer :digital_archival_object_properties

    def digital_archival_object_properties
      properties = %i[access_provided_by
                      extent
                      part_of
                      lat
                      long
                      alt
                      height
                      width
                      packaged_by_ids
                      in_archival_resource_ids]
      properties = base_properties + properties + common_properties
      properties.sort!
      @digital_archival_object_properties ||= properties
    end

    attr_writer :digital_archival_object_properties_required

    def digital_archival_object_properties_required
      @digital_archival_object_properties_required ||= required_properties
    end

    # PublishedWork

    attr_writer :published_work_properties
    def published_work_properties
      properties = %i[abstract
                      date_published
                      date_available
                      date_accepted
                      date_submitted
                      edition
                      editor
                      isbn
                      issue_number
                      official_url
                      pagination
                      part
                      place_of_publication
                      publication_status
                      refereed
                      series
                      volume_number]
      properties = base_properties + properties + common_properties
      properties.sort!
      @published_work_properties ||= properties
    end

    attr_writer :published_work_properties_required

    def published_work_properties_required
      @published_work_properties_required ||= required_properties
    end

    attr_writer :journal_article_properties

    def journal_article_properties
      properties = %i[abstract
                      date_published
                      date_available
                      date_accepted
                      date_submitted
                      issue_number
                      part_of
                      official_url
                      pagination
                      publication_status
                      refereed
                      volume_number]
      properties = base_properties + properties + common_properties
      properties.sort!
      @journal_article_properties ||= properties
    end

    attr_writer :journal_article_properties_required

    def journal_article_properties_required
      @journal_article_properties_required ||= required_properties
    end

    attr_writer :thesis_properties
    # omitting orcid
    def thesis_properties
      properties = %i[abstract
                      advisor
                      date_of_award
                      awarding_institution
                      qualification_level
                      qualification_name]
      properties = base_properties + properties + common_properties
      properties.sort!
      @thesis_properties ||= properties
    end

    attr_writer :thesis_properties_required

    def thesis_properties_required
      @thesis_properties_required ||= required_properties
    end

    attr_writer :exam_paper_properties

    def exam_paper_properties
      properties = %i[module_code
                      qualification_level
                      qualification_name
                      date_available]
      properties = base_properties + properties + common_properties
      properties.sort!
      @exam_paper_properties ||= properties
    end

    attr_writer :exam_paper_properties_required

    def exam_paper_properties_required
      @exam_paper_properties_required ||= required_properties
    end

    attr_writer :dataset_properties

    # omitting pure (_uuid, _creation, _type and _link),
    #   requestor_email
    #   these are admin info, not for standard form/view
    def dataset_properties
      properties = %i[
        abstract
        content_version
        date_accepted
        date_available
        date_collected
        date_copyrighted
        date_issued
        date_published
        date_submitted
        date_updated
        date_valid
        dc_access_rights
        dc_format
        extent
        has_restriction
        last_access
        number_of_downloads
        resource_type_general
        subtitle
      ]
      properties = base_properties + properties + common_properties
      properties.sort!
      @dataset_properties ||= properties
    end

    attr_writer :dataset_properties_required

    # use datacite mandatory
    #   exclude doi as this may be generated later in workflow
    def dataset_properties_required
      @dataset_properties_required ||= %i[
        creator
        title
        publisher
        date_published
        resource_type_general
        resource_type
      ]
    end

    attr_writer :package_properties

    def package_properties
      properties = %i[
        aip_uuid
        transfer_uuid
        sip_uuid
        dip_uuid
        aip_status
        dip_status
        aip_size
        dip_size
        aip_current_path
        dip_current_path
        aip_current_location
        dip_current_location
        aip_resource_uri
        dip_resource_uri
        origin_pipeline
        package_ids
        has_dao_ids
      ]
      properties = base_properties + properties + common_properties
      properties.sort!
      @package_properties ||= properties
    end

    attr_writer :package_properties_required

    def package_properties_required
      @package_properties_required ||= required_properties
    end

    # attr_writer :creator_class
    #
    # def creator_class
    #   @creator_class ||= String
    # end

    # Image

    attr_writer :image_properties

    def image_properties
      properties = %i[
        brand
        example_of_work
        product
        height
        width
      ]
      properties = base_properties + properties + common_properties
      properties.sort!
      @image_properties ||= properties
    end

    attr_writer :image_properties_required

    def image_properties_required
      @image_properties_required ||= required_properties
    end

    attr_writer :information_sheet_properties

    def information_sheet_properties
      properties = %i[
        brand
        product
        release_date
      ]
      properties = base_properties + properties + common_properties
      properties.sort!
      @information_sheet_properties ||= properties
    end

    attr_writer :archival_resource_properties_required

    def archival_resource_properties_required
      @archival_resource_properties_required ||= required_properties
    end

    attr_writer :archival_resource_properties

    def archival_resource_properties
      properties = %i[
        archival_level
        access_provided_by
        access_restrictions
        dates
        extent
        has_dao_ids
      ]
      properties = base_properties + properties + common_properties
      properties.sort!
      @archival_resource_properties ||= properties
    end

    attr_writer :information_sheet_properties_required

    def information_sheet_properties_required
      @information_sheet_properties_required ||= required_properties
    end
  end
end

# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/ClassLength
