# -*- encoding : utf-8 -*-

# Prevent all document attributes from being exposed through the API
class DocumentSerializer < ActiveModel::Serializer
  attributes :uid, :doi, :license, :license_url, :data_source, :authors,
             :title, :journal, :year, :volume, :number, :pages

  def fulltext_url
    object.fulltext_url ? object.fulltext_url.to_s : nil
  end
end
