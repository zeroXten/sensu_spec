
class Chef
  class Recipe

    def clean(name)
      name.gsub(/[^\w ]/,'').gsub(/[^\w]+/,'_')
    end

    def describe(name, &block)
      if node.run_state.has_key?('sensu_spec_tree')
        node.run_state['sensu_spec_tree'] << clean(name)
      else
        node.run_state['sensu_spec_tree'] = [clean(name)]
      end
      self.instance_eval &block
      node.run_state['sensu_spec_tree'].pop
    end

    def it(name)
      sensu_spec name do
        context node.run_state['sensu_spec_tree'].join('.')
      end
    end

    def define(name, &block)
      sensu_spec_definition(name, &block)
    end

  end
end
