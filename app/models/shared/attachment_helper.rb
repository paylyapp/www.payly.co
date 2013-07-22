module Shared
  module AttachmentHelper

    class << self
      def included(base)
        base.extend ClassMethods
      end
    end

    module ClassMethods
      def has_attachment(name, options = {})

        # generates a string containing the singular model name and the pluralized attachment name.
        # Examples: "user_avatars" or "asset_uploads" or "message_previews"
        attachment_owner    = self.table_name.singularize
        attachment_folder   = "#{attachment_owner}_#{name.to_s.pluralize}"

        # we want to create a path for the upload that looks like:
        # message_previews/00/11/22/001122deadbeef/thumbnail.png
        attachment_path     = "#{attachment_folder}/:id/:style.:extension"

        options[:path]            ||= attachment_path
        options[:storage]         ||= :s3
        options[:url]             ||= ':s3_authenticated_url'
        options[:s3_credentials]  ||= {
          :bucket => ENV['AWS_BUCKET'],
          :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
          :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
        }
        options[:s3_permissions]  ||= 'private'
        options[:s3_protocol]     ||= 'https'

        # pass things off to paperclip.
        has_attached_file name, options
      end
    end
  end
end