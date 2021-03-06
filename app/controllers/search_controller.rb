class SearchController < ApplicationController

  def index
    params[:q] ||= ""
    @results = Rails.cache.fetch("search#index:#{params[:q]}") do
      JSON.parse(`../e2tv-api/e2tv --search #{Shellwords.escape(params[:q])}`)
    end
  end

  def show
    @details = Rails.cache.fetch("search#show:details:#{params[:type]}:#{params[:id]}") do
      JSON.parse(`../e2tv-api/e2tv --details --#{params[:type]} #{params[:id]}`)
    end
    @sources = Rails.cache.fetch("search#show:sources:#{params[:type]}:#{params[:id]}") do
      JSON.parse(`../e2tv-api/e2tv --sources --#{params[:type]} #{params[:id]}`)
    end
    @image = ((@details['/common/topic/image'] || []).first || {})['id']
    @bg = @sources['bg']
    @poster = @sources['poster']
    @sources['sources'] ||= []
    @trailer = @sources['sources'].select {|s| s['kind'] == 'Trailer'}.first
    @rental = @sources['sources'].select {|s| s['kind'] == 'Rental'}.first
    @streaming = @sources['sources'].select {|s| s['kind'] == 'Streaming'}.first
    @torrents = @sources['sources'].select {|s| s['kind'] == 'Torrent'}
    @torrents.map {|t| t['filename']}.each do |filename|
      Rails.cache.write(filename[0..7].downcase, @bg) if filename.present?
    end
  end
end
