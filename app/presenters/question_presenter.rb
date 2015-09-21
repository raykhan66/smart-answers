class QuestionPresenter < NodePresenter
  def initialize(i18n_prefix, node, state = nil, options = {})
    super(i18n_prefix, node, state)
    @renderer = options[:renderer] || SmartAnswer::ErbRenderer.new(
      template_directory: @node.template_directory,
      template_name: @node.name.to_s,
      locals: @state.to_hash,
    )
  end

  def title
    title = @renderer.content_for(:title, html: false)
    title.present? ? title.chomp : super
  end

  def hint
    hint = @renderer.content_for(:hint, html: false)
    hint && hint.chomp
  end

  def label
    label = @renderer.content_for(:label, html: false)
    label && label.chomp
  end

  def suffix_label
    suffix_label = @renderer.content_for(:suffix_label, html: false)
    suffix_label && suffix_label.chomp
  end

  def error_message
    error_message = @renderer.content_for(:error_message, html: false)
    error_message && error_message.chomp
  end

  def options
    @node.options.map do |value, label|
      OpenStruct.new(label: label, value: value.to_s)
    end
  end

  def body(html: true)
    @renderer.content_for(:body, html: html)
  end

  def has_post_body?
    !!post_body
  end

  def post_body(html: true)
    @renderer.content_for(:post_body, html: html)
  end

  def response_label(value)
    value
  end

  def partial_template_name
    "#{@node.class.name.demodulize.underscore}_question"
  end

  def multiple_responses?
    false
  end
end
