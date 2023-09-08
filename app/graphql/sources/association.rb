class Sources::Association < ::GraphQL::Dataloader::Source
  def initialize(association_name, scope = nil)
    @association_name = association_name
    @scope = scope
  end

  def fetch(records)
    ::ActiveRecord::Associations::Preloader.new(records: records, associations: @association_name, scope: @scope).call
    records.map { |record| record.public_send(@association_name) }
  end

  # https://github.com/rmosolgo/graphql-ruby/blob/821ca53048fa5803fb90596719b4fedd65029ecb/lib/graphql/dataloader/source.rb#L113-L129
  def self.batch_key_for(*batch_args, **batch_kwargs)
    [*batch_args.map { |arg| arg.try(:to_sql) || arg }, **batch_kwargs]
  end
end
