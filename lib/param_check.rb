require "param_check/version"
require 'param_check/engine'

module ParamCheck
  extend self

  class ParameterError < StandardError; end

  class MockController
    include ParamCheck
    attr_accessor :params
  end

  def param! name, options, &block
    validate! name, params.try(:[], name), options

    if block_given?
      recurse params[name], &block
    end
  end

  private

  def recurse params, index = nil
    controller = MockController.new
    controller.params = params

    yield controller, index
  end

  def validate! name, value, options
    if options[:required]
      validate_presence name, value
    end

    if options[:type].present?
      validate_type name, value, options[:type]
    end

    if options[:min].present? || options[:max].present?
      validate_range name, value, options[:min], options[:max]
    end

    if options[:in].present?
      validate_inclusion name, value, options[:in]
    end
  end

  def validate_presence name, value
    if value.nil?
      raise ParameterError, I18n.t(
        'param_check.missing_required_parameter',
        parameter: name,
      )
    end
  end

  def validate_type name, value, type
    return if value.nil?

    if type.in?([Integer, Fixnum])
      is_numeric = Float(value) rescue nil
      if ! is_numeric
        raise ParameterError, I18n.t(
          'param_check.invalid_parameter',
          parameter: name,
          expected: type,
          got: value.class.name
        )
      end
    elsif ! value.is_a? type
      raise ParameterError, I18n.t(
        'param_check.invalid_parameter',
        parameter: name,
        expected: type,
        got: value.class.name
      )
    end
  end

  def validate_range name, value, min = nil, max = nil
    if min.present?
      if value.nil? || value.to_i < min.to_i
        raise ParameterError, I18n.t(
          'param_check.invalid_minimum',
          parameter: name,
          min: min,
          got: value,
        )
      end
    end

    if max.present?
      if value.nil? || value.to_i > max.to_i
        raise ParameterError, I18n.t(
          'param_check.invalid_maximum',
          parameter: name,
          max: max,
          got: value,
        )
      end
    end
  end

  def validate_inclusion name, value, inclusion = []
    if ! value.in?(inclusion)
      raise ParameterError, I18n.t(
        'param_check.invalid_inclusion',
        parameter: name,
        expected: inclusion,
        got: value,
      )
    end
  end
end
