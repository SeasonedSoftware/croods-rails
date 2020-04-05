# frozen_string_literal: true

require_relative 'policy/scope'

module Croods
  class Policy
    DEFAULT_ROLES = %i[owner admin].freeze

    def initialize(user, member)
      self.user = user
      self.member = member
    end

    protected

    cattr_writer :roles
    attr_accessor :user, :member

    def super?(role)
      return role?(role) unless Croods.multi_tenancy? && user && member_user

      role?(role) && member_user.tenant == user.tenant
    end

    def role?(role)
      user&.public_send("#{role}?")
    end

    def owner?
      return true unless member_user

      return false unless user

      member_user == user
    end

    def member_user
      return @member_user if @member_user

      return if member.instance_of?(Class)

      @member_user = reflection_user(member)
    end

    def reflection_user(member)
      return unless member

      return member.user if member.respond_to?(:user)

      associations = member.class.reflect_on_all_associations(:belongs_to)

      return if associations.empty?

      associations.each do |association|
        association_user = reflection_user(member.public_send(association.name))
        return association_user if association_user
      end

      nil
    end

    def authorize_action(action)
      return true if action.public

      roles = action.roles || DEFAULT_ROLES

      roles.each do |role|
        return true if authorize_role(role)
      end

      false
    end

    def authorize_role(role)
      return owner? if role.to_sym == :owner

      super?(role)
    end
  end
end
