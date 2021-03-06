# frozen_string_literal: true

module Croods
  class Action
    attr_accessor :name, :public, :roles, :method, :on, :block, :service

    def initialize(name, **options)
      self.name = name.to_sym
      self.public = options[:public]
      self.roles = options[:roles]
      self.method = options[:method]
      self.on = options[:on]
      self.block = options[:block]
      self.service = options[:service]
    end
  end
end
