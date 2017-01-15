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

  def validate! name, param, options
    if options[:required]
      validate_presence name, param
    end

    validate_type name, param, options[:type]
  end

  def validate_presence name, param
    if param.nil?
      raise ParameterError, I18n.t(
        'param_check.missing_required_parameter',
        parameter: name,
      )
    end
  end

  def validate_type name, param, type
    return if param.nil?

    if type.in?([Integer, Fixnum])
      is_numeric = Float(param) rescue nil
      if ! is_numeric
        raise ParameterError, I18n.t(
          'param_check.invalid_parameter',
          parameter: name,
          expected: type,
          got: param.class.name
        )
      end
    elsif ! param.is_a? type
      raise ParameterError, I18n.t(
        'param_check.invalid_parameter',
        parameter: name,
        expected: type,
        got: param.class.name
      )
    end
  end
end
