require "spec_helper"


describe ParamCheck do
  let(:param_check) { ParamCheck }

  it "has a version number" do
    expect(ParamCheck::VERSION).not_to be nil
  end

  describe 'param!' do
    context 'param exists' do
      context 'no block given' do
        before do
          expect(param_check).to receive(:params).and_return foo: 'bar'
        end

        it 'calls validate on the param' do
          expect(param_check).to receive(:validate!).with(:foo, 'bar', {required: true})
          param_check.param! :foo, {required: true}
        end
      end

      context 'block given' do
        before do
          expect(param_check).to receive(:params).twice.times.and_return foo: 'bar'
        end

        it 'calls validate on the param' do
          expect(param_check).to receive(:validate!).with(:foo, 'bar', {required: true})
          expect do |b|
            expect(param_check).to receive(:recurse).with('bar', &b)
          end
          param_check.param! :foo, {required: true} do |b| end
        end
      end
    end

    context 'param doesnt exists' do
      context 'no block given' do
        before do
          expect(param_check).to receive(:params).and_return(bar: 'foo')
        end

        it 'calls validate on the param' do
          expect(param_check).to receive(:validate!).with(:foo, nil, {required: true})
          param_check.param! :foo, {required: true}
        end
      end

      context 'block given' do
        before do
          expect(param_check).to receive(:params).twice.and_return(bar: 'foo')
        end

        it 'calls validate on the param' do
          expect(param_check).to receive(:validate!).with(:foo, nil, {required: true})
          expect do |b|
            expect(param_check).to receive(:recurse).with(nil, &b)
          end
          param_check.param! :foo, {required: true} do |b| end
        end
      end
    end
  end

  describe 'recurse' do
    let(:mock_controller) { double ParamCheck::MockController }

    before do
      expect(ParamCheck::MockController).to receive(:new).and_return mock_controller
      expect(mock_controller).to receive(:params=).with(foo: 'bar')
    end

    it 'creates a new instance of the MockController' do
      expect do |b|
        param_check.send :recurse, foo: 'bar', &b
      end.to yield_with_args(
        mock_controller,
        nil
      )
    end
  end

  describe 'validate_presence' do
    it 'raises an error if the param is not present' do
      expect{
        param_check.send :validate_presence, 'foo', nil
      }.to raise_error(ParamCheck::ParameterError,
        I18n.t('param_check.missing_required_parameter', parameter: 'foo')
      )
    end
  end

  describe 'validate_type' do
    context 'param is nil' do
      it 'returns early' do
        expect{
          param_check.send :validate_type, 'foo', nil, Integer
        }.to_not raise_error
      end
    end

    context 'param type is invalid' do
      it 'raises an error if type is string but expected integer' do
        expect{
          param_check.send :validate_type, 'foo', 'bar', Integer
        }.to raise_error(ParamCheck::ParameterError,
          I18n.t('param_check.invalid_parameter', parameter: 'foo', expected: Integer, got: String)
        )
      end

      it 'raises an error if type is fixnum but expected string' do
        expect{
          param_check.send :validate_type, 'foo', 1, String
        }.to raise_error(ParamCheck::ParameterError,
          I18n.t('param_check.invalid_parameter', parameter: 'foo', expected: String, got: Fixnum)
        )
      end
    end

    context 'param type is valid' do
      it 'does not raise an error if param is Fixnum and integer expected' do
        expect{
          param_check.send :validate_type, 'foo', 1, Integer
        }.to_not raise_error
      end

      it 'does not raise an error if param is string and string expected' do
        expect{
          param_check.send :validate_type, 'foo', '1', String
        }.to_not raise_error
      end
    end
  end

  describe 'validate_number' do
    context 'less than' do
      context 'value is more than' do
        it 'raises an error' do
          expect {
            param_check.send :validate_number, 'foo', 3, { lt: 2 }
          }.to raise_error(ParamCheck::ParameterError,
            I18n.t('param_check.value_not_less_than', parameter: 'foo', expected: 2, got: 3)
          )
        end
        it 'raises an error' do
          expect {
            param_check.send :validate_number, 'foo', 2.1, { lt: 2 }
          }.to raise_error(ParamCheck::ParameterError,
            I18n.t('param_check.value_not_less_than', parameter: 'foo', expected: 2, got: 2.1)
          )
        end
      end

      context 'value is equal to' do
        it 'raises an error' do
          expect {
            param_check.send :validate_number, 'foo', 3, { lt: 3 }
          }.to raise_error(ParamCheck::ParameterError,
            I18n.t('param_check.value_not_less_than', parameter: 'foo', expected: 3, got: 3)
          )
        end
        it 'raises an error' do
          expect {
            param_check.send :validate_number, 'foo', 3.0, { lt: 3 }
          }.to raise_error(ParamCheck::ParameterError,
            I18n.t('param_check.value_not_less_than', parameter: 'foo', expected: 3, got: 3.0)
          )
        end
      end

      context 'value is less than' do
        it 'succeeds' do
          expect {
            param_check.send :validate_number, 'foo', 2, { less_than: 3 }
          }.to_not raise_error
        end
        it 'succeeds' do
          expect {
            param_check.send :validate_number, 'foo', 2.9, { less_than: 3 }
          }.to_not raise_error
        end
      end
    end

    context 'less than equal to' do
      context 'value is more than' do
        it 'raises an error' do
          expect {
            param_check.send :validate_number, 'foo', 3, { lte: 2 }
          }.to raise_error(ParamCheck::ParameterError,
            I18n.t('param_check.value_not_less_than_equal_to', parameter: 'foo', expected: 2, got: 3)
          )
        end
        it 'raises an error' do
          expect {
            param_check.send :validate_number, 'foo', 2.2, { lte: 2 }
          }.to raise_error(ParamCheck::ParameterError,
            I18n.t('param_check.value_not_less_than_equal_to', parameter: 'foo', expected: 2, got: 2.2)
          )
        end
      end

      context 'value is equal to' do
        it 'succeeds' do
          expect {
            param_check.send :validate_number, 'foo', 3, { less_than_equal_to: 3 }
          }.to_not raise_error
        end
        it 'succeeds' do
          expect {
            param_check.send :validate_number, 'foo', 3.0, { less_than_equal_to: 3 }
          }.to_not raise_error
        end
      end

      context 'value is less than' do
        it 'succeeds' do
          expect {
            param_check.send :validate_number, 'foo', 2, { less_than_equal_to: 3 }
          }.to_not raise_error
        end
        it 'succeeds' do
          expect {
            param_check.send :validate_number, 'foo', 2.2, { less_than_equal_to: 3 }
          }.to_not raise_error
        end
      end
    end

    context 'more than' do
      context 'value is less than' do
        it 'raises an error' do
          expect {
            param_check.send :validate_number, 'foo', 1, { mt: 2 }
          }.to raise_error(ParamCheck::ParameterError,
            I18n.t('param_check.value_not_more_than', parameter: 'foo', expected: 2, got: 1)
          )
        end
        it 'raises an error' do
          expect {
            param_check.send :validate_number, 'foo', 1.9, { mt: 2 }
          }.to raise_error(ParamCheck::ParameterError,
            I18n.t('param_check.value_not_more_than', parameter: 'foo', expected: 2, got: 1.9)
          )
        end
      end

      context 'value is equal to' do
        it 'raises an error' do
          expect {
            param_check.send :validate_number, 'foo', 2, { mt: 2 }
          }.to raise_error(ParamCheck::ParameterError,
            I18n.t('param_check.value_not_more_than', parameter: 'foo', expected: 2, got: 2)
          )
        end
        it 'raises an error' do
          expect {
            param_check.send :validate_number, 'foo', 2.0, { mt: 2 }
          }.to raise_error(ParamCheck::ParameterError,
            I18n.t('param_check.value_not_more_than', parameter: 'foo', expected: 2, got: 2.0)
          )
        end
      end

      context 'value is more than' do
        it 'succeeds' do
          expect {
            param_check.send :validate_number, 'foo', 3, { mt: 2 }
          }.to_not raise_error
        end
        it 'succeeds' do
          expect {
            param_check.send :validate_number, 'foo', 2.1, { mt: 2 }
          }.to_not raise_error
        end
      end
    end

    context 'more than equal to' do
      context 'value is less than' do
        it 'raises an error' do
          expect {
            param_check.send :validate_number, 'foo', 1, { mte: 2 }
          }.to raise_error(ParamCheck::ParameterError,
            I18n.t('param_check.value_not_more_than_equal_to', parameter: 'foo', expected: 2, got: 1)
          )
        end
        it 'raises an error' do
          expect {
            param_check.send :validate_number, 'foo', 1.9, { mte: 2 }
          }.to raise_error(ParamCheck::ParameterError,
            I18n.t('param_check.value_not_more_than_equal_to', parameter: 'foo', expected: 2, got: 1.9)
          )
        end
      end

      context 'value is equal to' do
        it 'raises an error' do
          expect {
            param_check.send :validate_number, 'foo', 2, { mte: 2 }
          }.to_not raise_error
        end
        it 'raises an error' do
          expect {
            param_check.send :validate_number, 'foo', 2.0, { mte: 2 }
          }.to_not raise_error
        end
      end

      context 'value is more than' do
        it 'succeeds' do
          expect {
            param_check.send :validate_number, 'foo', 3, { mte: 2 }
          }.to_not raise_error
        end
        it 'succeeds' do
          expect {
            param_check.send :validate_number, 'foo', 2.1, { mte: 2 }
          }.to_not raise_error
        end
      end
    end
  end

  describe 'validate_inclusion' do
    it 'raises an error if param not in the list' do
      expect {
        param_check.send :validate_inclusion, 'foo', 'foo', ['bar', 'baz']
      }.to raise_error(ParamCheck::ParameterError,
        I18n.t('param_check.invalid_inclusion', parameter: 'foo', got: 'foo', expected: ['bar', 'baz'])
      )

      expect {
        param_check.send :validate_inclusion, 'foo', 3, 1..2
      }.to raise_error(ParamCheck::ParameterError,
        I18n.t('param_check.invalid_inclusion', parameter: 'foo', got: 3, expected: '1..2')
      )
    end
  end
end
