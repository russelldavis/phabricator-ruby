require_relative '../conduit_client'

module Phabricator::Maniphest
  class Task
    module Priority
      # TODO: Make these priority values actually correct, or figure out
      # how to pull these programmatically.
      PRIORITIES = {
        needs_triage: 100,
        unbreak_now: 90,
        high: 80,
        normal: 70,
        low: 60,
        wishlist: 50
      }

      PRIORITIES.each do |priority, value|
        define_method(priority) do
          value
        end
      end
    end

    attr_reader :id
    attr_accessor :title, :description, :priority

    def self.create(title, description=nil, projects=[], priority=Priority.normal, other={})
      response = JSON.parse(client.request(:post, 'maniphest.createtask', {
        title: title,
        description: description,
        priority: priority,
        projectPHIDs: projects.map {|p| Phabricator::Project.find_by_name(p).phid }
      }.merge(other)))

      data = response['result']

      # TODO: Error handling

      self.new(data)
    end

    def initialize(attributes)
      @id = attributes['id']
      @title = attributes['title']
      @description = attributes['description']
      @priority = attributes['priority']
    end

    private

    def self.client
      @client ||= Phabricator::ConduitClient.instance
    end
  end
end