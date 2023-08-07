class MessagesController < ApplicationController
  before_action :set_message, only: %i[show edit update destroy]

  def index
    @messages = Message.all.order(created_at: :desc)
  end

  def show; end

  def new
    @message = Message.new
  end

  def edit
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(@message, partial: 'messages/form', locals: { message: @message })
      end
    end
  end

  def create
    @message = Message.new(message_params)

    respond_to do |format|
      if @message.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new_message', partial: 'messages/form', locals: { message: Message.new }),
            turbo_stream.prepend('messages', partial: 'messages/message', locals: { message: @message }),
            turbo_stream.update('message_counter', html: Message.count),
            turbo_stream.update('notice', html: 'Message created successfully')
          ]
        end
        format.html { redirect_to message_url(@message), notice: 'Message was successfully created.' }
        format.json { render :show, status: :created, location: @message }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new_message', partial: 'messages/form', locals: { message: @message })
          ]
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @message.update(message_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(@message, partial: 'messages/message', locals: { message: @message }),
            turbo_stream.update('notice', html: 'Message updated successfully')
          ]
        end
        format.html { redirect_to message_url(@message), notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @message.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("message_#{@message.id}"),
          turbo_stream.update('message_counter', html: Message.count),
          turbo_stream.update('notice', html: 'Message deleted successfully')
        ]
      end
    end
  end

  private

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
