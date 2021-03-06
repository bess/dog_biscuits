# frozen_string_literal: true
require 'rails/generators'
require 'rails/generators/model_helpers'

class DogBiscuits::WorkGenerator < Rails::Generators::NamedBase
  include Rails::Generators::ModelHelpers
  source_root File.expand_path('../templates', __FILE__)

  class_option :skipmodel, type: :boolean, default: false

  desc '
This generator makes the following changes to your application:
    The DogBiscuits Work generator makes the following changes to your application:
    1. Checks that the requested Work is supported by DogBiscuits
    2. Runs the Hyrax generator for the given model
    3. Creates a new model, form, presenter and indexer to replace the Hyrax one
    4. Creates views/hyrax/work_name_plural/_attribute_rows.html.erb
    5. Updates the schema_org config, hyrax (en) locale using the configured properties for the work
    (If this is a Hyku application, it also enables UV / IIIF)
       '

  def banner
    say_status("info", "CREATING DOG BISCUITS WORK: #{class_name}", :blue)
  end

  def supported_model
    unless DogBiscuits.config.available_models.include? class_name
      say_status("error", "UNSUPPORTED MODEL. SUPPORTED MODELS ARE: #{DogBiscuits.config.available_models.map { |m| m }.join(', ')}", :red)
      exit 0
    end
  end

  def hyrax_work_generator
    unless options[:force]
      if File.exist? File.join('app/models/', class_path, "#{file_name}.rb")
        question = 'It looks like you ran the Hyrax work generator. Changes to the generated files will be overwritten. Continue?)'
        answer = ask question, default: 'Y'
        unless answer == 'Y'
          say_status("info", "CANCELLING", :red)
          exit 0
        end
      end
    end
    say_status("info", "RUNNING rails generate hyrax:work #{class_name}", :blue)
    generate "hyrax:work #{class_name}", '-f'
  end
  
  def create_actor
    template('actor.rb.erb', File.join('app/actors/hyrax/actors', class_path, "#{file_name}_actor.rb"))
  end
  
  def create_indexer
    if options[:skipmodel]
      say_status("info", "SKIPPING INDEXER GENERATION", :blue)
    else
      template('indexer.rb.erb', File.join('app/indexers', class_path, "#{file_name}_indexer.rb"))
    end
  end
  
  def create_model
    if options[:skipmodel]
      say_status("info", "SKIPPING MODEL GENERATION", :blue)
    else
      template('model.rb.erb', File.join('app/models/', class_path, "#{file_name}.rb"))
    end
  end
  
  def create_form
    template('form.rb.erb', File.join('app/forms/hyrax', class_path, "#{file_name}_form.rb"))
  end
  
  def create_presenter
    generate "dog_biscuits:presenter #{class_name}", '-f'
  end
  
  def create_attribute_rows
    attributes_file = "app/views/hyrax/#{file_name.pluralize}/_attribute_rows.html.erb"
    copy_file '_attribute_rows.html.erb', attributes_file
  end

  def update_locales
    generate 'dog_biscuits:locales', '-f'
  end

  def create_schema_org
    generate 'dog_biscuits:schema_org', '-f'
  end

  def display_readme
    readme 'README'
  end
end
