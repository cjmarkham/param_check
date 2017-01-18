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

  def validate_number name, value, options = {}
    options[:lt] = options[:less_than] if options[:less_than].present?
    options[:lte] = options[:less_than_equal_to] if options[:less_than_equal_to].present?
    options[:mt] = options[:more_than] if options[:more_than].present?
    options[:more_than_equal_to] = options[:more_than_equal_to] if options[:more_than_equal_to].present?

    if options[:lt].present?
      raise ParameterError, I18n.t(
        'param_check.value_not_less_than',
        parameter: name,
        expected: options[:lt],
        got: value,
      ) if value >= options[:lt]
    end

    if options[:lte].present?
      raise ParameterError, I18n.t(
        'param_check.value_not_less_than_equal_to',
        parameter: name,
        expected: options[:lte],
        got: value,
      ) if value > options[:lte]
    end

    if options[:mt].present?
      raise ParameterError, I18n.t(
        'param_check.value_not_more_than',
        parameter: name,
        expected: options[:mt],
        got: value,
      ) if value <= options[:mt]
    end

    if options[:mte].present?
      raise ParameterError, I18n.t(
        'param_check.value_not_more_than_equal_to',
        parameter: name,
        expected: options[:mte],
        got: value,
      ) if value < options[:mte]
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
