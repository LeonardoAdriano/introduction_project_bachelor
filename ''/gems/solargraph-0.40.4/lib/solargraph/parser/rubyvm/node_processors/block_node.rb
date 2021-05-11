# frozen_string_literal: true

module Solargraph
  module Parser
    module Rubyvm
      module NodeProcessors
        class BlockNode < Parser::NodeProcessor::Base
          def process
            pins.push Solargraph::Pin::Block.new(
              location: get_node_location(node),
              closure: region.closure,
              receiver: node.children[0],
              comments: comments_for(node),
              scope: region.scope || region.closure.context.scope
            )
            process_children region.update(closure: pins.last)
          end
        end
      end
    end
  end
end
