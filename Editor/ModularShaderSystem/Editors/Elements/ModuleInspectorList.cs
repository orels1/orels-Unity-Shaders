using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine;
using UnityEngine.UIElements;

namespace ORL.ModularShaderSystem.UI
{

    public class ModuleInspectorList : BindableElement, IInspectorList
    {
        Foldout _listContainer;
        Button _addButton;
        SerializedProperty _array;
        private bool _showElementsButtons;
        private List<string> _loadedModules;

        private bool _hasFoldingBeenForced;

        public InspectorListItem draggedElement { get; set; }
        public bool _highlightDrops;

        private List<VisualElement> _drops;

        private VisualElement _currentDrop;

        public ModuleInspectorList()
        {
            _drops = new List<VisualElement>();
            _listContainer = new Foldout();
            _listContainer.text = "Unbound List";
            _listContainer.contentContainer.AddToClassList("inspector-list-container");
            _listContainer.value = false;
            _listContainer.RegisterCallback<MouseUpEvent>(e => Drop());
            _listContainer.RegisterCallback<MouseLeaveEvent>(e => Drop());

            _addButton = new Button(AddItem);
            _addButton.text = "Add";
            _addButton.AddToClassList("inspector-list-add-button");
            Add(_listContainer);
            if (enabledSelf)
                _listContainer.Add(_addButton);
            _listContainer.RegisterValueChangedCallback((e) => _array.isExpanded = e.newValue);
            var styleSheet = Resources.Load<StyleSheet>(MSSConstants.RESOURCES_FOLDER + "/MSSUIElements/InspectorList");
            styleSheets.Add(styleSheet);
        }

        private void Drop()
        {
            if (draggedElement == null) return;
            draggedElement.RemoveFromClassList("inspector-list-drag-enabled");

            if (_highlightDrops)
            {
                DeHighlightDrops();
                int dropIndex = _drops.IndexOf(_currentDrop);

                if (dropIndex == -1)
                {
                    draggedElement = null;
                    return;
                }

                if (dropIndex > draggedElement.index) dropIndex--;
                _array.MoveArrayElement(draggedElement.index, dropIndex);
                bool expanded = _array.GetArrayElementAtIndex(dropIndex).isExpanded;
                _array.GetArrayElementAtIndex(dropIndex).isExpanded = _array.GetArrayElementAtIndex(draggedElement.index).isExpanded;
                _array.GetArrayElementAtIndex(draggedElement.index).isExpanded = expanded;
                _array.serializedObject.ApplyModifiedProperties();
                UpdateList();
            }
            draggedElement = null;
        }

        public void HighlightDrops()
        {
            foreach (var item in _drops)
                item.AddToClassList("inspector-list-drop-area-highlight");

            _highlightDrops = true;
        }

        public void DeHighlightDrops()
        {
            foreach (var item in _drops)
                item.RemoveFromClassList("inspector-list-drop-area-highlight");

            _highlightDrops = false;
        }

        public override void HandleEvent(EventBase evt)
        {
            var type = evt.GetType(); //SerializedObjectBindEvent is internal, so need to use reflection here
            if ((type.Name == "SerializedPropertyBindEvent") && !string.IsNullOrWhiteSpace(bindingPath))
            {
                var obj = type.GetProperty("bindProperty")?.GetValue(evt) as SerializedProperty;
                _array = obj;
                if (obj != null)
                {
                    if (_hasFoldingBeenForced) obj.isExpanded = _listContainer.value;
                    else _listContainer.value = obj.isExpanded;
                }
                UpdateList();
            }
            base.HandleEvent(evt);
        }

        public void UpdateList()
        {
            _listContainer.Clear();
            _drops.Clear();

            if (_array == null)
                return;
            _listContainer.text = _array.displayName;
            CreateDrop();

            _loadedModules = new List<string>();
            for (int i = 0; i < _array.arraySize; i++)
            {
                if (_array.GetArrayElementAtIndex(i).objectReferenceValue != null)
                    _loadedModules.Add(((ShaderModule)_array.GetArrayElementAtIndex(i).objectReferenceValue)?.Id);
            }



            for (int i = 0; i < _array.arraySize; i++)
            {
                int index = i;

                var moduleItem = new VisualElement();
                var objectField = new ObjectField();//_array.GetArrayElementAtIndex(index));

                SerializedProperty propertyValue = _array.GetArrayElementAtIndex(index);

                objectField.objectType = typeof(ShaderModule);
                objectField.bindingPath = propertyValue.propertyPath;
                objectField.Bind(propertyValue.serializedObject);
                var infoLabel = new Label();
                moduleItem.Add(objectField);
                moduleItem.Add(infoLabel);

                objectField.RegisterCallback<ChangeEvent<Object>>(x =>
                {
                    var newValue = (ShaderModule)x.newValue;
                    var oldValue = (ShaderModule)x.previousValue;

                    if (oldValue != null)
                        _loadedModules.Remove(oldValue.Id);
                    if (newValue != null)
                        _loadedModules.Add(newValue.Id);

                    for (int j = 0; j < _array.arraySize; j++)
                    {
                        var element = ((ObjectField)x.target).parent.parent.parent.ElementAt(j*2+1).ElementAt(1);
                        Label label = element.ElementAt(1) as Label;
                        if (index == j)
                            CheckModuleValidity(newValue, label, element);
                        else
                            CheckModuleValidity((ShaderModule)_array.GetArrayElementAtIndex(j).objectReferenceValue, label, element);
                    }
                });

                var item = new InspectorListItem(this, moduleItem, _array, index, _showElementsButtons);
                item.removeButton.RegisterCallback<PointerUpEvent>((evt) => RemoveItem(index));
                item.upButton.RegisterCallback<PointerUpEvent>((evt) => MoveUpItem(index));
                item.downButton.RegisterCallback<PointerUpEvent>((evt) => MoveDownItem(index));
                _listContainer.Add(item);
                CreateDrop();

                CheckModuleValidity((ShaderModule)propertyValue.objectReferenceValue, infoLabel, moduleItem);
            }
            if (enabledSelf)
                _listContainer.Add(_addButton);
        }

        private void CreateDrop()
        {
            VisualElement dropArea = new VisualElement();
            dropArea.AddToClassList("inspector-list-drop-area");
            dropArea.RegisterCallback<MouseEnterEvent>(e =>
            {
                if (_highlightDrops)
                {
                    dropArea.AddToClassList("inspector-list-drop-area-selected");
                    _currentDrop = dropArea;
                }
            });
            dropArea.RegisterCallback<MouseLeaveEvent>(e =>
            {
                if (_highlightDrops)
                {
                    dropArea.RemoveFromClassList("inspector-list-drop-area-selected");
                    if (_currentDrop == dropArea) _currentDrop = null;
                }
            });

            _listContainer.Add(dropArea);
            _drops.Add(dropArea);
        }

        private void CheckModuleValidity(ShaderModule newValue, Label infoLabel, VisualElement moduleItem)
        {

            List<string> problems = new List<string>();

            if (newValue != null)
            {
                var moduleId = newValue.Id;
                if (_loadedModules.Count(y => y.Equals(moduleId)) > 1)
                    problems.Add("The module is duplicate");

                List<string> missingDependencies = newValue.ModuleDependencies.Where(dependency => _loadedModules.Count(y => y.Equals(dependency)) == 0).ToList();
                List<string> incompatibilities = newValue.IncompatibleWith.Where(dependency => _loadedModules.Count(y => y.Equals(dependency)) > 0).ToList();

                if (missingDependencies.Count > 0)
                    problems.Add("Missing dependencies: " + string.Join(", ", missingDependencies));

                if (incompatibilities.Count > 0)
                    problems.Add("These incompatible modules are installed: " + string.Join(", ", incompatibilities));
            }

            infoLabel.text = string.Join("\n", problems);

            if (!string.IsNullOrWhiteSpace(infoLabel.text))
            {
                moduleItem.AddToClassList("error-background");
                infoLabel.visible = true;
            }
            else
            {
                moduleItem.RemoveFromClassList("error-background");
                infoLabel.visible = false;
            }
        }

        public void RemoveItem(int index)
        {
            if (_array != null)
            {
                if (index < _array.arraySize - 1)
                    _array.GetArrayElementAtIndex(index).isExpanded = _array.GetArrayElementAtIndex(index + 1).isExpanded;
                var elementProperty = _array.GetArrayElementAtIndex(index);
                if (elementProperty.objectReferenceValue != null)
                    elementProperty.objectReferenceValue = null;
                _array.DeleteArrayElementAtIndex(index);
                _array.serializedObject.ApplyModifiedProperties();
            }

            UpdateList();
        }

        public void MoveUpItem(int index)
        {
            if (_array != null && index > 0)
            {
                _array.MoveArrayElement(index, index - 1);
                bool expanded = _array.GetArrayElementAtIndex(index).isExpanded;
                _array.GetArrayElementAtIndex(index).isExpanded = _array.GetArrayElementAtIndex(index - 1).isExpanded;
                _array.GetArrayElementAtIndex(index - 1).isExpanded = expanded;
                _array.serializedObject.ApplyModifiedProperties();
            }

            UpdateList();
        }

        public void MoveDownItem(int index)
        {
            if (_array != null && index < _array.arraySize - 1)
            {
                _array.MoveArrayElement(index, index + 1);
                bool expanded = _array.GetArrayElementAtIndex(index).isExpanded;
                _array.GetArrayElementAtIndex(index).isExpanded = _array.GetArrayElementAtIndex(index + 1).isExpanded;
                _array.GetArrayElementAtIndex(index + 1).isExpanded = expanded;
                _array.serializedObject.ApplyModifiedProperties();
            }

            UpdateList();
        }

        public void AddItem()
        {
            if (_array != null)
            {
                _array.InsertArrayElementAtIndex(_array.arraySize);
                _array.serializedObject.ApplyModifiedProperties();
            }

            UpdateList();
        }

        public void SetFoldingState(bool open)
        {
            _listContainer.value = open;
            if (_array != null) _array.isExpanded = open;
            else _hasFoldingBeenForced = true;
        }

        public new class UxmlFactory : UxmlFactory<ModuleInspectorList, UxmlTraits> { }

        public new class UxmlTraits : BindableElement.UxmlTraits
        {
            UxmlBoolAttributeDescription showElements =
                new UxmlBoolAttributeDescription { name = "show-elements-text", defaultValue = true };

            public override void Init(VisualElement ve, IUxmlAttributes bag, CreationContext cc)
            {
                base.Init(ve, bag, cc);

                if (ve is ModuleInspectorList ate) ate._showElementsButtons = showElements.GetValueFromBag(bag, cc);
            }
        }
    }
}