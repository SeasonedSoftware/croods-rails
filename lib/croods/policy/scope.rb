# frozen_string_literal: true

module Croods
  class Policy
    class Scope
      def initialize(tenant:, user:, scope:)
        self.user  = user
        self.scope = scope
        self.tenant = user&.tenant || tenant
      end

      def resolve
        self.scope = scope.where(tenant_scope) if multi_tenancy?

        return scope if super?

        return scope unless owner? && scope.has_attribute?(:user_id)

        scope.where(user_id: user.id)
      end

      protected

      attr_accessor :tenant, :user, :scope

      def multi_tenancy?
        return unless Croods.multi_tenancy?

        scope.has_attribute?(Croods.tenant_attribute)
      end

      def tenant_scope
        { Croods.tenant_attribute => tenant.id }
      end

      def super?
        super_roles.each do |role|
          return true if user&.send("#{role}?")
        end

        false
      end

      def roles
        action.roles || DEFAULT_ROLES
      end

      def super_roles
        roles.reject { |role| role == :owner }
      end

      def owner?
        roles.include?(:owner)
      end
    end
  end
end
