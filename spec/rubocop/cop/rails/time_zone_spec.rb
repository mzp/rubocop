# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Rails::TimeZone, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is "always"' do
    let(:cop_config) { { 'EnforcedStyle' => 'always' } }

    described_class::TIMECLASS.each do |klass|
      it "registers an offense for #{klass}.now" do
        inspect_source(cop, "#{klass}.now")
        expect(cop.offenses.size).to eq(1)
      end

      it "registers an offense for #{klass}.now" do
        new_source = autocorrect_source(cop, "#{klass}.now")
        expect(new_source).to eq('Time.zone.now')
      end

      it "registers an offense for #{klass}.now.in_time_zone" do
        inspect_source(cop, "#{klass}.now.in_time_zone")
        expect(cop.offenses.size).to eq(1)
      end

      it "registers an offense for #{klass}.new" do
        inspect_source(cop, "#{klass}.new(2012, 6, 10, 12, 00)")
        expect(cop.offenses.size).to eq(1)
      end
    end

    it 'registers an offense for Time.parse' do
      inspect_source(cop, 'Time.parse("2012-03-02 16:05:37")')
      expect(cop.offenses.size).to eq(1)
    end

    it 'corrects an offense for Time.parse' do
      new_source = autocorrect_source(cop, 'Time.parse("2012-03-02 16:05:37")')
      expect(new_source).to eq('Time.zone.parse("2012-03-02 16:05:37")')
    end

    it 'registers an offense for Time.strptime' do
      inspect_source(cop, 'Time.strptime(time_string, "%Y-%m-%dT%H:%M:%S%z")')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for Time.strptime.in_time_zone' do
      inspect_source(
        cop,
        'Time.strptime(time_string, "%Y-%m-%dT%H:%M:%S%z").in_time_zone'
      )
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for Time.strptime with nested Time.zone' do
      inspect_source(
        cop,
        'Time.strptime(Time.zone.now.to_s, "%Y-%m-%dT%H:%M:%S%z")'
      )
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for Time.zone.strptime with nested Time.now' do
      inspect_source(
        cop,
        'Time.zone.strptime(Time.now.to_s, "%Y-%m-%dT%H:%M:%S%z")'
      )
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for Time.at' do
      inspect_source(cop, 'Time.at(ts)')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for Time.at.in_time_zone' do
      inspect_source(cop, 'Time.at(ts).in_time_zone')
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts Time.zone.now' do
      inspect_source(cop, 'Time.zone.now')
      expect(cop.offenses).to be_empty
    end

    it 'accepts Time.zone.today' do
      inspect_source(cop, 'Time.zone.today')
      expect(cop.offenses).to be_empty
    end

    it 'accepts Time.zone.local' do
      inspect_source(cop, 'Time.zone.local(2012, 6, 10, 12, 00)')
      expect(cop.offenses).to be_empty
    end

    it 'accepts Time.zone.parse' do
      inspect_source(cop, 'Time.zone.parse("2012-03-02 16:05:37")')
      expect(cop.offenses).to be_empty
    end

    it 'accepts Time.zone.at' do
      inspect_source(cop, 'Time.zone.at(ts)')
      expect(cop.offenses).to be_empty
    end

    it 'accepts Time.zone.strptime' do
      inspect_source(
        cop,
        'Time.zone.strptime(time_string, "%Y-%m-%dT%H:%M:%S%z")'
      )
      expect(cop.offenses).to be_empty
    end
  end

  context 'when EnforcedStyle is "ignore_acceptable"' do
    let(:cop_config) { { 'EnforcedStyle' => 'acceptable' } }

    described_class::TIMECLASS.each do |klass|
      it "accepts #{klass}.now.in_time_zone" do
        inspect_source(cop, "#{klass}.now.in_time_zone")
        expect(cop.offenses).to be_empty
      end
    end

    it 'accepts Time.strptime.in_time_zone' do
      inspect_source(
        cop,
        'Time.strptime(time_string, "%Y-%m-%dT%H:%M:%S%z").in_time_zone'
      )
      expect(cop.offenses).to be_empty
    end
  end
end
